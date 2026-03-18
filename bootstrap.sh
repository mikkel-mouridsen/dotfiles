#!/usr/bin/env bash
# ── Dotfiles Bootstrap ──────────────────────────────────────────
# One-liner: curl -fsSL https://raw.githubusercontent.com/mikkel-mouridsen/dotfiles/main/bootstrap.sh | bash
set -euo pipefail

DOTFILES_REPO="https://github.com/mikkel-mouridsen/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

log()  { echo -e "\033[1;34m==>\033[0m $*"; }
ok()   { echo -e "\033[1;32m ✓\033[0m $*"; }
fail() { echo -e "\033[1;31m ✗\033[0m $*"; exit 1; }

# ── 1. Detect distro ────────────────────────────────────────────
DISTRO="unknown"
PKG_INSTALL=""

if [[ "$OSTYPE" == "darwin"* ]]; then
  DISTRO="macos"
  PKG_INSTALL="brew install"
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
  case "${ID:-}" in
    arch|cachyos|endeavouros|manjaro) DISTRO="arch"; PKG_INSTALL="sudo pacman -S --needed --noconfirm" ;;
    fedora)                           DISTRO="fedora"; PKG_INSTALL="sudo dnf install -y" ;;
    ubuntu|pop|linuxmint)             DISTRO="ubuntu"; PKG_INSTALL="sudo apt-get install -y" ;;
    debian)                           DISTRO="debian"; PKG_INSTALL="sudo apt-get install -y" ;;
    *)                                fail "Unsupported distro: ${ID:-unknown}" ;;
  esac
fi

log "Detected: $DISTRO"

# ── 2. Install git if missing ───────────────────────────────────
if ! command -v git &>/dev/null; then
  log "Installing git..."
  $PKG_INSTALL git || fail "Could not install git"
fi
ok "git available"

# ── 3. Clone or pull dotfiles ───────────────────────────────────
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  log "Updating existing dotfiles..."
  git -C "$DOTFILES_DIR" pull --rebase
else
  log "Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi
ok "dotfiles at $DOTFILES_DIR"

# ── 4. Install Bun ──────────────────────────────────────────────
if ! command -v bun &>/dev/null; then
  log "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi
ok "bun $(bun --version)"

# ── 5. Install Zig (required by OpenTUI native bindings) ───────
if ! command -v zig &>/dev/null; then
  log "Installing Zig..."
  case "$DISTRO" in
    arch)   $PKG_INSTALL zig ;;
    fedora) $PKG_INSTALL zig ;;
    *)
      # Manual install for distros without a zig package
      ZIG_VERSION="0.13.0"
      ZIG_ARCH="$(uname -m)"
      [[ "$ZIG_ARCH" == "aarch64" ]] && ZIG_ARCH="aarch64" || ZIG_ARCH="x86_64"
      ZIG_URL="https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz"
      log "Downloading Zig ${ZIG_VERSION}..."
      curl -fsSL "$ZIG_URL" | tar -xJ -C /tmp
      sudo mv "/tmp/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}" /usr/local/zig
      sudo ln -sf /usr/local/zig/zig /usr/local/bin/zig
      ;;
  esac
fi
ok "zig $(zig version)"

# ── 6. Install stow if missing ──────────────────────────────────
if ! command -v stow &>/dev/null; then
  log "Installing stow..."
  $PKG_INSTALL stow || fail "Could not install stow"
fi
ok "stow available"

# ── 7. Install TUI dependencies ─────────────────────────────────
log "Installing TUI dependencies..."
cd "$DOTFILES_DIR/tui"
bun install
ok "TUI dependencies installed"

# ── 8. Launch TUI ───────────────────────────────────────────────
log "Launching dotfiles manager..."
echo ""
exec bun run "$DOTFILES_DIR/tui/index.ts"
