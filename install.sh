#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(nvim tmux ghostty starship bat git neofetch zsh claude)

# ── Detect OS ────────────────────────────────────────────────────
OS="$(uname -s)"
echo "Detected OS: $OS"

# ── Install stow if missing ─────────────────────────────────────
if ! command -v stow &>/dev/null; then
  echo "Installing GNU Stow..."
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

# ── Stow each package ───────────────────────────────────────────
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
echo "  - ANTHROPIC_BASE_URL, NODE_AUTH_TOKEN, etc."
echo ""
echo "Create ~/.gitconfig.local for machine-specific git config:"
echo "  [user]"
echo "      name = Your Name"
echo "      email = your@email.com"
echo "  [commit]"
echo "      template = ~/path/to/template.txt  # optional"
echo ""
echo "Run 'tmux' then press prefix + I to install tmux plugins."
echo "Open 'nvim' to let Lazy.nvim install plugins."
