# ── Editor ───────────────────────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim

# ── Pager ────────────────────────────────────────────────────────
set -gx MANPAGER "nvim +Man!"

# ── FZF defaults (non-theme options) ────────────────────────────
# Theme-specific --color= is set by generated conf.d/theme.fish
set -gx FZF_DEFAULT_OPTS "\
  --height=40% \
  --layout=reverse \
  --border=rounded \
  --info=inline \
  --preview-window=right:60%:wrap"

set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"

# ── Misc ─────────────────────────────────────────────────────────
set -gx TERM xterm-256color
