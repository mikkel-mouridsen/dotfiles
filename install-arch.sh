#!/usr/bin/env bash
# ── install-arch.sh ──────────────────────────────────────────────
# CachyOS / Arch Linux bootstrap for the Hyprland dotfiles.
# Run once on a fresh install, then run ./install.sh to stow packages.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
ERRORS=()

log()  { echo -e "\033[1;34m==>\033[0m $*"; }
ok()   { echo -e "\033[1;32m ✓\033[0m $*"; }
warn() { echo -e "\033[1;33m !\033[0m $*"; ERRORS+=("$*"); }

# ── 1. pacman packages ───────────────────────────────────────────
log "Installing pacman packages…"
PACMAN_PKGS=(
  # Shell / terminal
  fish tmux ghostty starship bat fzf zoxide jq fd ripgrep eza vivid

  # Editor
  neovim python-pynvim

  # Wayland / Hyprland
  hyprland xdg-desktop-portal-hyprland hyprlock hypridle
  mako swww wl-clipboard grim slurp
  qt5-wayland qt6-wayland

  # Quickshell dependencies
  qt6-declarative qt6-wayland imagemagick

  # System utils
  stow git lazygit yazi fastfetch brightnessctl

  # Fonts
  noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols

  # Media
  playerctl pipewire wireplumber pavucontrol
)

sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || warn "Some pacman packages failed — check output above"

# ── 2. AUR packages (paru preferred, fall back to yay) ──────────
log "Installing AUR packages…"
AUR_HELPER=""
if command -v paru &>/dev/null; then
  AUR_HELPER=paru
elif command -v yay &>/dev/null; then
  AUR_HELPER=yay
else
  warn "No AUR helper found (paru/yay). Installing paru…"
  sudo pacman -S --needed --noconfirm base-devel git
  git clone https://aur.archlinux.org/paru.git /tmp/paru-build
  (cd /tmp/paru-build && makepkg -si --noconfirm)
  AUR_HELPER=paru
fi

AUR_PKGS=(
  quickshell-git             # Quickshell — QML-based desktop shell for Wayland
  kanata-bin                 # keyboard remapper (pre-built binary, faster than kanata)
)

$AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}" || warn "Some AUR packages failed — check output above"

# ── 3. kanata: input group + uinput udev rule ────────────────────
log "Configuring kanata permissions…"
# Create uinput group if it doesn't exist yet
if ! getent group uinput &>/dev/null; then
  sudo groupadd uinput
  ok "Created uinput group"
fi
sudo usermod -aG input,uinput "$USER" || warn "Could not add $USER to input/uinput groups"

UDEV_RULE='/etc/udev/rules.d/99-uinput.rules'
if [[ ! -f "$UDEV_RULE" ]]; then
  echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' \
    | sudo tee "$UDEV_RULE" > /dev/null
  sudo udevadm control --reload-rules && sudo udevadm trigger
  ok "uinput udev rule created"
else
  ok "uinput udev rule already exists"
fi

# kanata systemd user service
KANATA_SERVICE="$HOME/.config/systemd/user/kanata-laptop.service"
mkdir -p "$(dirname "$KANATA_SERVICE")"
if [[ ! -f "$KANATA_SERVICE" ]]; then
  cat > "$KANATA_SERVICE" <<'EOF'
[Unit]
Description=kanata keyboard remapper (laptop built-in keyboard)
After=default.target

[Service]
ExecStart=/usr/bin/kanata --cfg %h/.config/kanata/laptop.kbd
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF
  systemctl --user daemon-reload
  systemctl --user enable --now kanata-laptop.service || warn "kanata service failed to start (reboot may be required for group changes)"
  ok "kanata-laptop.service installed and enabled"
else
  ok "kanata-laptop.service already exists"
fi

# ── 4. fisher (fish plugin manager) ──────────────────────────────
log "Bootstrapping fish + fisher…"
if command -v fish &>/dev/null; then
  fish -c "
    if not functions -q fisher
      curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
      fisher install jorgebucaran/fisher
    end
    fisher install PatrickF1/fzf.fish jorgebucaran/autopair.fish
  " || warn "fisher plugin install failed"
  ok "fish plugins installed"
else
  warn "fish not found — skipping fisher bootstrap"
fi

# ── 5. chsh to fish ─────────────────────────────────────────────
log "Setting default shell to fish…"
FISH_PATH="$(command -v fish)"
if ! grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
  echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
fi
if [[ "$SHELL" != "$FISH_PATH" ]]; then
  chsh -s "$FISH_PATH" || warn "chsh failed — change shell manually"
  ok "Default shell changed to fish (takes effect on next login)"
else
  ok "fish is already the default shell"
fi

# ── 6. Wallpaper + screenshots dirs ──────────────────────────────
log "Creating wallpaper directory…"
mkdir -p "$HOME/.config/wallpapers"
ok "Wallpaper dir created — add images to ~/.config/wallpapers/"
mkdir -p "$HOME/Pictures/Screenshots"

# ── 7. Run install.sh ────────────────────────────────────────────
log "Running install.sh to stow all packages…"
bash "$DOTFILES_DIR/install.sh"

# ── Summary ──────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════"
if [[ ${#ERRORS[@]} -eq 0 ]]; then
  echo -e "\033[1;32mAll done!\033[0m No errors."
else
  echo -e "\033[1;33mDone with warnings:\033[0m"
  for e in "${ERRORS[@]}"; do
    echo "  - $e"
  done
fi
echo ""
echo "Next steps:"
echo "  1. Log out and back in (group changes, new shell)"
echo "  2. Start Hyprland: exec Hyprland"
echo "  3. Tmux: C-Space I  (install plugins)"
echo "  4. Neovim: opens and auto-installs plugins via Lazy"
echo "  5. Add wallpapers to ~/.config/wallpapers/"
echo "  6. Set kanata device: echo '/dev/input/by-path/...' > ~/.config/kanata/device.local"
echo "════════════════════════════════════════════════════"
