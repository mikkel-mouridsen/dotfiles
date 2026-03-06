#!/usr/bin/env bash
set -euo pipefail

echo "=== Fedora Software Installer ==="
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
  libnotify

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
  if command -v cargo &>/dev/null; then
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

# ── Set default shell to zsh ────────────────────────────────────
if [[ "$SHELL" != */zsh ]]; then
  echo ""
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

echo ""
echo "=== Software installation complete! ==="
echo ""
echo "Now run ./install.sh to stow the dotfiles."
