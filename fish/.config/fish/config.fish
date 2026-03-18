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
