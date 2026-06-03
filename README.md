# dotfiles

My Hyprland + [Noctalia](https://github.com/noctalia-dev/noctalia-shell) desktop on CachyOS,
managed with [chezmoi](https://www.chezmoi.io/).

## Install on a new machine

One line. Everything after it is a graphical installer — no terminal needed.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/mikkel-mouridsen/dotfiles/main/bootstrap.sh)"
```

It installs prerequisites, clones this repo, asks whether the machine is a
*desktop* or *laptop*, then opens a [zenity](https://help.gnome.org/users/zenity/)
GUI that installs every package, applies the dotfiles, and adds Hyprland as a
session you can pick at login. GNOME and your login manager are left untouched.

Afterwards, re-add the two secrets that are deliberately **not** in this repo:

- `gh auth login` — GitHub authentication
- Noctalia → *NAS Manager* settings — your SMB share password

## Day-to-day syncing

The **Dotfiles** widget in the Noctalia bar (the `dotfiles-sync` plugin) shows
drift at a glance and gives you three buttons:

| Button | Runs |
|--------|------|
| **Pull** | `chezmoi update` (git pull --ff-only + apply) |
| **Push** | `chezmoi re-add` + `git add -A` + commit + `git push` |
| **View diff** | `chezmoi diff` |

Or from a shell:

```sh
chezmoi update           # pull + apply
chezmoi re-add           # capture live edits back into the source
chezmoi cd               # drop into the source repo to commit/push
```

## What's tracked

- **Desktop shell:** `hypr/` (Hyprland), `noctalia/` (shell + plugins, incl. the
  self-authored `nas-manager` and `dotfiles-sync`)
- **Terminal & shell:** `fish/`, `ghostty/`
- **Editors:** `nvim/` (LazyVim), `micro/`, VSCode `settings.json`
- **CLI & system:** `fcitx5/`, plus `packages/{pacman,aur}.txt` (the reinstall manifest)

Secrets (GitHub token, SMB/VPN credentials) are excluded via `home/.chezmoiignore`.

## Layout

```
bootstrap.sh                 one-paste entrypoint
install/gui-installer.sh     the zenity GUI
install/zenity-askpass.sh    graphical sudo password helper
packages/{pacman,aur}.txt    package manifest
home/                        chezmoi source dir (see .chezmoiroot)
```
