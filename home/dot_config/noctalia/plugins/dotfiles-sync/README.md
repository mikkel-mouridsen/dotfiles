# Dotfiles Sync

A Noctalia plugin that keeps your [chezmoi](https://www.chezmoi.io/)-managed
dotfiles in sync, with a bar widget and a Pull / Push / Diff panel.

## Bar widget

An icon that reflects sync state, with a count badge:

| Icon | State |
|------|-------|
| `cloud-check` | up to date |
| `cloud-upload` + badge | local edits / unpushed commits to **push** |
| `cloud-download` + badge | commits to **pull** |
| `arrows-exchange` | diverged (both sides changed) |
| `refresh` (spinning) | a pull/push is running |
| `alert-triangle` | last operation errored |

Left-click opens the panel; right-click is a quick menu (Pull / Push / Refresh / Settings).

## Panel

- Current state + last-sync time
- List of locally changed files (`chezmoi status`)
- **Pull** → `chezmoi update`  ·  **Push** → `chezmoi re-add` + commit + `git push`  ·  **View diff** → `chezmoi diff`

## IPC

```sh
qs -c noctalia-shell ipc call plugin:dotfiles-sync pull
qs -c noctalia-shell ipc call plugin:dotfiles-sync push
qs -c noctalia-shell ipc call plugin:dotfiles-sync refresh
```

## Settings

Commit-message template (`{host}` → hostname), status poll interval,
auto-fetch interval, notifications toggle, chezmoi binary path, terminal, icon color.

Requires `chezmoi` on `PATH` and a chezmoi source repo with a git remote.
