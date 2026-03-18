# ── Bootstrap ────────────────────────────────────────────────────
# conf.d/ files are sourced automatically by fish in alphabetical order.
# This file handles tools that need interactive-shell init.

# ── Zoxide ───────────────────────────────────────────────────────
if command -q zoxide
    zoxide init fish | source
end

# ── Starship ─────────────────────────────────────────────────────
if command -q starship
    starship init fish | source
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
