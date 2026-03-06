#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(nvim tmux ghostty starship bat git neofetch zsh claude)

echo "=== Fedora Dotfiles Installer ==="
echo ""

# ── Core tools via dnf ───────────────────────────────────────────
echo "Installing packages via dnf..."
sudo dnf install -y \
  stow \
  zsh \
  tmux \
  neovim \
  bat \
  fzf \
  zoxide \
  jq \
  git \
  fastfetch \
  libnotify   # for notify-send

# ── Starship ─────────────────────────────────────────────────────
if ! command -v starship &>/dev/null; then
  echo "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# ── Lazygit ──────────────────────────────────────────────────────
if ! command -v lazygit &>/dev/null; then
  echo "Installing Lazygit..."
  sudo dnf copr enable -y atim/lazygit
  sudo dnf install -y lazygit
fi

# ── Yazi ─────────────────────────────────────────────────────────
if ! command -v yazi &>/dev/null; then
  echo "Installing Yazi..."
  cargo_available=false
  if command -v cargo &>/dev/null; then
    cargo_available=true
  fi

  if [[ "$cargo_available" == true ]]; then
    cargo install --locked yazi-fm yazi-cli
  else
    echo "SKIP: Yazi requires cargo. Install Rust first: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  fi
fi

# ── Vivid (LS_COLORS generator) ─────────────────────────────────
if ! command -v vivid &>/dev/null; then
  echo "Installing Vivid..."
  if command -v cargo &>/dev/null; then
    cargo install vivid
  else
    echo "SKIP: Vivid requires cargo. Install Rust first."
  fi
fi

# ── Antidote (zsh plugin manager) ────────────────────────────────
if [[ ! -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
  echo "Installing Antidote..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
fi

# ── TPM (tmux plugin manager) ───────────────────────────────────
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ── Stow all packages ───────────────────────────────────────────
echo ""
echo "Stowing dotfiles..."
cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  echo "  Stowing $pkg..."
  stow -v --target="$HOME" "$pkg" 2>&1
done

# ── Set default shell to zsh ────────────────────────────────────
if [[ "$SHELL" != */zsh ]]; then
  echo ""
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

echo ""
echo "=== Done! ==="
echo ""
echo "── Reminders ─────────────────────────────────────────────────"
echo ""
echo "1. Create ~/.zshrc.local for machine-specific config (secrets, etc.)"
echo "2. Create ~/.gitconfig.local:"
echo "     [user]"
echo "         name = Your Name"
echo "         email = your@email.com"
echo ""
echo "3. Open tmux and press C-Space I to install plugins"
echo "4. Open nvim to let Lazy.nvim install plugins"
echo "5. Log out and back in (or run 'zsh') for shell change to take effect"
