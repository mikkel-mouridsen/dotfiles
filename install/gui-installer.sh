#!/bin/sh
# ============================================================================
#  Graphical dotfiles installer (zenity). Launched by bootstrap.sh.
#
#  Flow:   Welcome  ->  Install packages  ->  Apply dotfiles
#          ->  Hyprland session note  ->  Re-enter secrets note  ->  Done
#
#  No terminal interaction: the password is collected once via a graphical
#  askpass dialog, then the sudo timestamp is kept warm for the run.
# ============================================================================
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASKPASS="$ROOT/install/zenity-askpass.sh"
PACMAN_LIST="$ROOT/packages/pacman.txt"
AUR_LIST="$ROOT/packages/aur.txt"
W=480

export SUDO_ASKPASS="$ASKPASS"
KEEP_PID=""

cleanup() { [ -n "$KEEP_PID" ] && kill "$KEEP_PID" 2>/dev/null; }
trap cleanup EXIT INT TERM

fail() {
    cleanup
    zenity --error --width=$W --title="Dotfiles installer" --text="$1" 2>/dev/null
    exit 1
}

# Run "$@", streaming its output into a pulsating progress dialog.
# Returns the command's real exit status (not zenity's).
run_step() {
    _title="$1"; shift
    _rc="$(mktemp)"
    { "$@" 2>&1; echo $? >"$_rc"; } \
        | stdbuf -oL sed 's/^/# /' \
        | zenity --progress --pulsate --no-cancel --auto-close \
                 --width=$W --title="Dotfiles installer" --text="$_title" 2>/dev/null
    _status="$(cat "$_rc" 2>/dev/null)"; rm -f "$_rc"
    return "${_status:-1}"
}

# ---------------------------------------------------------------- 1. Welcome
zenity --question --width=$W --title="Dotfiles installer" \
    --ok-label="Install" --cancel-label="Quit" \
    --text="<b>Set up this machine to match your Hyprland + Noctalia desktop.</b>

This will:
  • Install your packages (Hyprland, Noctalia, fish, nvim, …)
  • Apply your dotfiles with chezmoi
  • Add Hyprland as a session you can pick at login

GNOME and your login screen are left untouched.
You'll be asked for your password once." 2>/dev/null \
    || exit 0

# ----------------------------------------------------- 2. Prime sudo (1 prompt)
sudo -A -v || fail "Authentication failed or cancelled."
# Keep the sudo timestamp warm during the long package install.
( while true; do sudo -n -v 2>/dev/null || exit; sleep 30; done ) &
KEEP_PID=$!

# ------------------------------------------------------------- 3. Packages
command -v paru >/dev/null 2>&1 || fail "paru not found (expected on CachyOS)."
if [ -f "$PACMAN_LIST" ] || [ -f "$AUR_LIST" ]; then
    PKGS="$(cat "$PACMAN_LIST" "$AUR_LIST" 2>/dev/null)"
    printf '%s\n' "$PKGS" \
        | run_step "Installing packages — this can take a while…" \
              paru -S --needed --noconfirm - \
        || fail "Package installation failed. See the terminal for details."
fi

# --------------------------------------------------------- 4. Apply dotfiles
run_step "Applying your dotfiles…" chezmoi apply --force \
    || fail "chezmoi apply failed."

# Stop the sudo keep-alive; nothing else needs root.
cleanup; KEEP_PID=""

# ----------------------------------------------- 5. Hyprland session present?
if [ ! -f /usr/share/wayland-sessions/hyprland.desktop ]; then
    zenity --warning --width=$W --title="Dotfiles installer" \
        --text="Hyprland session file not found. You may need to install the
<tt>hyprland</tt> package before it appears at the login screen." 2>/dev/null
fi

# --------------------------------------------------- 6. Re-enter your secrets
zenity --info --width=$W --title="One last thing" \
    --text="<b>A couple of secrets were intentionally left out of the repo.</b>

After you log into Hyprland, set them up again:
  • <tt>gh auth login</tt> — re-authenticate GitHub
  • Noctalia → NAS Manager settings — re-enter your share password

Your dotfiles sync panel will then show everything is up to date." 2>/dev/null

# ------------------------------------------------------------------ 7. Done
zenity --info --width=$W --title="All set 🎉" \
    --text="<b>Your desktop is installed.</b>

Log out, then choose <b>Hyprland</b> from the session menu (gear icon) on the
login screen.

From then on, the <b>Dotfiles</b> widget in your Noctalia bar keeps this
machine in sync — Pull, Push, and View&#160;diff." 2>/dev/null
