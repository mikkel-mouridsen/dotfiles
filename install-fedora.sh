#!/usr/bin/env bash
set -uo pipefail

echo "=== Fedora Software Installer ==="
echo ""

INSTALLED=()
FAILED=()
SKIPPED=()

try_install() {
  local name="$1"
  shift
  if "$@"; then
    INSTALLED+=("$name")
  else
    FAILED+=("$name")
  fi
}

# ── Core tools via dnf ───────────────────────────────────────────
echo "Installing packages via dnf..."
try_install "dnf packages" sudo dnf install -y \
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
if command -v starship &>/dev/null; then
  SKIPPED+=("Starship (already installed)")
else
  echo "Installing Starship..."
  try_install "Starship" bash -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y'
fi

# ── Lazygit ──────────────────────────────────────────────────────
if command -v lazygit &>/dev/null; then
  SKIPPED+=("Lazygit (already installed)")
else
  echo "Installing Lazygit..."
  sudo dnf copr enable -y atim/lazygit
  try_install "Lazygit" sudo dnf install -y lazygit
fi

# ── Yazi ─────────────────────────────────────────────────────────
if command -v yazi &>/dev/null; then
  SKIPPED+=("Yazi (already installed)")
elif command -v cargo &>/dev/null; then
  echo "Installing Yazi..."
  try_install "Yazi" cargo install --locked --force yazi-fm yazi-cli
else
  SKIPPED+=("Yazi (no cargo -- install Rust first)")
fi

# ── Vivid (LS_COLORS generator) ─────────────────────────────────
if command -v vivid &>/dev/null; then
  SKIPPED+=("Vivid (already installed)")
elif command -v cargo &>/dev/null; then
  echo "Installing Vivid..."
  try_install "Vivid" cargo install vivid
else
  SKIPPED+=("Vivid (no cargo -- install Rust first)")
fi

# ── Antidote (zsh plugin manager) ────────────────────────────────
if [[ -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
  SKIPPED+=("Antidote (already installed)")
else
  echo "Installing Antidote..."
  try_install "Antidote" git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
fi

# ── TPM (tmux plugin manager) ───────────────────────────────────
if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
  SKIPPED+=("TPM (already installed)")
else
  echo "Installing TPM..."
  try_install "TPM" git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ── Set default shell to zsh ────────────────────────────────────
if [[ "$SHELL" != */zsh ]]; then
  echo ""
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)" || FAILED+=("chsh to zsh")
fi

# ── Summary ──────────────────────────────────────────────────────
echo ""
echo "=== Summary ==="
echo ""
if (( ${#INSTALLED[@]} > 0 )); then
  echo "Installed:"
  for item in "${INSTALLED[@]}"; do echo "  + $item"; done
fi
if (( ${#SKIPPED[@]} > 0 )); then
  echo "Skipped:"
  for item in "${SKIPPED[@]}"; do echo "  - $item"; done
fi
if (( ${#FAILED[@]} > 0 )); then
  echo "FAILED:"
  for item in "${FAILED[@]}"; do echo "  ! $item"; done
  echo ""
  echo "Re-run this script after fixing the failures above."
fi
echo ""
echo "Now run ./install.sh to stow the dotfiles."
