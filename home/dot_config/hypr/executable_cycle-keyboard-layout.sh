#!/usr/bin/env bash
# Cycle fcitx5 input method: English (US) -> Danish -> Japanese (mozc) -> ...
# Bound to a key in hyprland.conf because fcitx5's own hotkey is unreliable
# under Wayland (it only sees keys when an app actively engages the IME grab).

order=(keyboard-us keyboard-dk mozc)
labels=("English (US)" "Danish" "日本語 (Mozc)")

current=$(fcitx5-remote -n)

next_index=0
for i in "${!order[@]}"; do
  if [[ "${order[$i]}" == "$current" ]]; then
    next_index=$(((i + 1) % ${#order[@]}))
    break
  fi
done

fcitx5-remote -s "${order[$next_index]}"

# Best-effort on-screen feedback.
if command -v notify-send >/dev/null; then
  notify-send -t 1000 -h string:x-canonical-private-synchronous:kblayout \
    "Keyboard: ${labels[$next_index]}"
fi
