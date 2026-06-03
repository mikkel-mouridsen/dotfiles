#!/bin/sh
# ============================================================================
#  Dotfiles bootstrap — the ONLY terminal step.
#
#  Run once on a fresh machine:
#
#      sh -c "$(curl -fsSL https://raw.githubusercontent.com/mikkel-mouridsen/dotfiles/main/bootstrap.sh)"
#
#  It installs the few prerequisites, clones the dotfiles, then hands off to a
#  graphical (zenity) installer. Everything after this is point-and-click.
# ============================================================================
set -eu

REPO_USER="mikkel-mouridsen"
REPO_NAME="dotfiles"
REPO_URL="https://github.com/${REPO_USER}/${REPO_NAME}.git"

note() { printf '\033[1;36m==>\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "Do not run this as root; run as your normal user."
command -v pacman >/dev/null 2>&1 || die "This installer targets Arch/CachyOS (pacman not found)."

note "Installing prerequisites (git, chezmoi, zenity, paru)…"
# paru ships on CachyOS; --needed makes this a no-op if already present.
sudo pacman -S --needed --noconfirm git chezmoi zenity paru

note "Fetching dotfiles into ~/.local/share/chezmoi …"
# `chezmoi init` clones the repo and runs the chassis prompt (desktop/laptop).
# We deliberately do NOT apply here — the GUI does that with a progress bar.
if [ -d "$(chezmoi source-path 2>/dev/null)" ]; then
    chezmoi init        # already initialised: just refresh config
else
    chezmoi init "$REPO_URL"
fi

ROOT="$(dirname "$(chezmoi source-path)")"
GUI="$ROOT/install/gui-installer.sh"
[ -f "$GUI" ] || die "Graphical installer not found at $GUI"
chmod +x "$GUI" "$ROOT/install/zenity-askpass.sh" 2>/dev/null || true

note "Launching the graphical installer…"
exec sh "$GUI"
