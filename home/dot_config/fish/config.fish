source /usr/share/cachyos-fish-config/cachyos-config.fish

# Show fastfetch on each new interactive shell
function fish_greeting
    if command -q fastfetch
        fastfetch
    end
end
export PATH="$HOME/.local/bin:$PATH"
