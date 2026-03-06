#!/bin/bash
# Sends a desktop notification when Claude Code needs attention.
# Reads JSON from stdin with fields: message, title, notification_type

input=$(cat)
title=$(echo "$input" | jq -r '.title // "Claude Code"')
message=$(echo "$input" | jq -r '.message // "Needs your attention"')

# Include the tmux window name/index so you know which window needs attention
if [ -n "$TMUX" ]; then
  win_index=$(tmux display-message -p '#I')
  win_name=$(tmux display-message -p '#W')
  title="$title [$win_index:$win_name]"
fi

case "$(uname -s)" in
  Darwin)
    # macOS: use osascript
    esc_title=${title//\"/\\\"}
    esc_message=${message//\"/\\\"}
    osascript -e "display notification \"$esc_message\" with title \"$esc_title\" sound name \"Funk\""
    ;;
  Linux)
    # Linux: use notify-send (libnotify)
    if command -v notify-send &>/dev/null; then
      notify-send "$title" "$message"
    fi
    ;;
esac
