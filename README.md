# Dotfiles

Personal dotfiles for Arch/CachyOS + Hyprland, managed with [GNU Stow](https://www.gnu.org/software/stow/) and an interactive TUI.

## Quick Start

One-liner bootstrap for a fresh system:

```bash
curl -fsSL https://raw.githubusercontent.com/mikkel-mouridsen/dotfiles/main/bootstrap.sh | bash
```

This installs dependencies (git, bun, stow), clones the repo, and launches the TUI to interactively select what to install.

## TUI Installer

The TUI (`tui/`) is a Bun + TypeScript interactive installer with module selection, dependency resolution, and real-time progress.

```bash
cd ~/dotfiles && bun run tui/index.ts
```

Choose "Fresh Install" to start with recommended defaults, or "Manage Existing" to add/remove modules.

## Modules

### Shell
| Module | Description |
|--------|-------------|
| `fish` | Fish shell with fisher, fzf, zoxide, autopair |
| `starship` | Cross-shell prompt with git/language segments |
| `zsh` | Z shell with antidote plugin manager |

### Terminal
| Module | Description |
|--------|-------------|
| `tmux` | Terminal multiplexer with Catppuccin theme |
| `ghostty` | GPU-accelerated terminal emulator |

### Editor
| Module | Description |
|--------|-------------|
| `nvim` | Neovim with LazyVim + Catppuccin |

### Dev Tools
| Module | Description |
|--------|-------------|
| `git` | Git config, aliases, delta diff, global ignore |
| `claude` | Claude Code settings, hooks, and skills |
| `gh-dash` | GitHub TUI dashboard for PRs and issues |

### Appearance
| Module | Description |
|--------|-------------|
| `bat` | Syntax-highlighted cat with Catppuccin theme |

### System
| Module | Description |
|--------|-------------|
| `fastfetch` | Fast system info with custom ASCII art |
| `kanata` | Keyboard remapper (Caps Lock → Ctrl/Esc) |
| `tailscale` | Mesh VPN with tsui dashboard |

### Storage
| Module | Description |
|--------|-------------|
| `network-storage` | SMB mounts via Tailscale — bidirectional sync for Documents/Music/Pictures/Videos, mount-only for Media |

### Desktop (Arch + Hyprland)
| Module | Description |
|--------|-------------|
| `hyprland` | Dynamic tiling Wayland compositor |
| `quickshell` | QML desktop shell — bar, launcher, control center, wallpaper picker |
| `mako` | Notification daemon with Catppuccin theme |
| `hyprlock` | Screen locker + idle daemon |
| `greetd` | Login greeter with blurred wallpaper |

### Social
| Module | Description |
|--------|-------------|
| `vesktop` | Discord client with Vencord + Catppuccin |

## Machine-Specific Config

These local override files are **not** tracked:

- **`~/.gitconfig.local`** — `[user]` name/email
- **`~/.config/network-storage/config.env`** — SMB server address, sync settings
- **`~/.config/network-storage/.smbcredentials`** — SMB credentials

## Manual Stow Commands

```bash
cd ~/dotfiles

stow <package>        # Create symlinks
stow -D <package>     # Remove symlinks
stow -R <package>     # Re-stow (after adding files)
```
