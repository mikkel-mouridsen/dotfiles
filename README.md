# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Packages

| Package    | What it manages                          |
|------------|------------------------------------------|
| `nvim`     | Neovim config (LazyVim)                  |
| `tmux`     | tmux config (TPM plugins auto-install)   |
| `ghostty`  | Ghostty terminal config                  |
| `starship` | Starship prompt config                   |
| `bat`      | bat config + Catppuccin theme            |
| `git`      | Shared gitconfig + global ignore         |
| `neofetch` | Neofetch config                          |
| `zsh`      | Shared .zshrc + antidote plugin list     |
| `claude`   | Claude Code settings, hooks, and skills  |
| `gh-dash`  | GitHub dashboard config (gh-dash)        |

## Machine-Specific Config

Shared configs source local override files that are **not** tracked in this repo:

- **`~/.zshrc.local`** -- secrets, work CLIs, machine-specific PATH additions
- **`~/.gitconfig.local`** -- `[user]` name/email, `[commit]` template

## Managing Packages

```bash
# Stow a single package
cd ~/dotfiles && stow <package>

# Unstow (remove symlinks)
cd ~/dotfiles && stow -D <package>

# Re-stow (unstow then stow -- useful after adding files)
cd ~/dotfiles && stow -R <package>
```

## After Install

- **tmux**: Open tmux, press `C-Space I` to install plugins via TPM
- **nvim**: Open nvim, Lazy.nvim will auto-install plugins on first launch
- **zsh**: Create `~/.zshrc.local` with your secrets and machine-specific config
- **git**: Create `~/.gitconfig.local` with your `[user]` block
- **gh-dash**: Run `gh dash`. Add repos to `repoPaths` in `~/.config/gh-dash/config.yml` to enable keybindings (`g` lazygit, `C` Claude Code PR review)
