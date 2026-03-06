#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(nvim tmux ghostty starship bat git neofetch zsh claude)

echo "=== Dotfiles Setup ==="
echo ""

# ── Install stow if missing ─────────────────────────────────────
if ! command -v stow &>/dev/null; then
  echo "Installing GNU Stow..."
  OS="$(uname -s)"
  case "$OS" in
    Darwin)
      brew install stow
      ;;
    Linux)
      if command -v dnf &>/dev/null; then
        sudo dnf install -y stow
      elif command -v apt-get &>/dev/null; then
        sudo apt-get install -y stow
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm stow
      else
        echo "ERROR: Could not detect package manager. Install stow manually."
        exit 1
      fi
      ;;
    *)
      echo "ERROR: Unsupported OS: $OS"
      exit 1
      ;;
  esac
fi

# ── Back up conflicting files ────────────────────────────────────
echo "Checking for conflicting files..."
CONFLICTS=(
  ~/.zshrc
  ~/.zsh_plugins.txt
  ~/.gitconfig
  ~/.config/nvim
  ~/.config/tmux/tmux.conf
  ~/.config/ghostty/config
  ~/.config/starship.toml
  ~/.config/bat/config
  ~/.config/bat/themes/Catppuccin-Mocha.tmTheme
  ~/.config/git/ignore
  ~/.config/neofetch/config.conf
  ~/.claude/settings.json
  ~/.claude/hooks/notify.sh
  ~/.claude/skills/pr-feedback
  ~/.claude/skills/vault-writer
  ~/.claude/skills/weekly-review
)
for f in "${CONFLICTS[@]}"; do
  if [[ -e "$f" && ! -L "$f" ]]; then
    echo "  Backing up $f -> ${f}.bak"
    mv "$f" "${f}.bak"
  elif [[ -L "$f" ]]; then
    rm -f "$f"
  fi
done

# ── Create parent directories stow expects ──────────────────────
mkdir -p ~/.config/{tmux,ghostty,bat/themes,git,neofetch}
mkdir -p ~/.claude/{hooks,skills}

# ── Stow each package ───────────────────────────────────────────
echo ""
cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  echo "Stowing $pkg..."
  stow -v --target="$HOME" "$pkg"
done

echo ""
echo "All packages stowed successfully!"
echo ""
echo "── Reminders ─────────────────────────────────────────────────"
echo ""
echo "Create ~/.zshrc.local for machine-specific config:"
echo "  - Secrets (API tokens, env vars)"
echo "  - Work-specific CLIs and functions"
echo ""
echo "Create ~/.gitconfig.local for machine-specific git config:"
echo "  [user]"
echo "      name = Your Name"
echo "      email = your@email.com"
echo ""
echo "Run 'tmux' then press C-Space I to install tmux plugins."
echo "Open 'nvim' to let Lazy.nvim install plugins."
