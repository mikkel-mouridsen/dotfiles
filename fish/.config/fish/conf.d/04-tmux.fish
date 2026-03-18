# ── Auto-start tmux on login shells ─────────────────────────────
# Only attach/create if: interactive, no existing tmux client, not inside tmux already.
if status is-interactive
    and not set -q TMUX
    and not set -q TMUX_PASSTHROUGH
    and command -q tmux
    # Attach to existing session named "main", or create it.
    tmux new-session -A -s main
end
