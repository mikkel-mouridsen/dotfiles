import type { DotfilesModule, Distro } from "./types";

const UNIX_ONLY: Distro[] = ["arch", "fedora", "ubuntu", "debian", "macos"];

export const modules: DotfilesModule[] = [
  // ─── Shell ───────────────────────────────────────────────────
  {
    id: "fish",
    name: "Fish Shell",
    description: "Modern shell with autosuggestions, syntax highlighting, and fisher plugin manager",
    category: "shell",
    core: true,
    stowPackages: ["fish"],
    systemPackages: {
      pacman: ["fish", "fzf", "zoxide", "fd", "ripgrep", "eza", "vivid"],
      dnf: ["fish", "fzf", "zoxide"],
      apt: ["fish", "fzf"],
      brew: ["fish", "fzf", "zoxide", "fd", "ripgrep", "eza", "vivid"],
    },
    dirs: [
      "~/.config/fish/conf.d",
      "~/.config/fish/functions",
    ],
    postInstall: [
      {
        description: "Install fisher plugin manager and plugins",
        command: `fish -c "
          if not functions -q fisher
            curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
            fisher install jorgebucaran/fisher
          end
          fisher install PatrickF1/fzf.fish jorgebucaran/autopair.fish
        "`,
      },
      {
        description: "Set fish as default shell",
        command: `FISH_PATH="$(command -v fish)" && grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null && [ "$SHELL" != "$FISH_PATH" ] && chsh -s "$FISH_PATH" || true`,
      },
    ],
    onlyOn: UNIX_ONLY,
    manualSteps: [
      "Log out and back in for shell change to take effect",
    ],
  },
  {
    id: "starship",
    name: "Starship Prompt",
    description: "Cross-shell prompt with git status, language versions, and custom segments",
    category: "shell",
    core: true,
    stowPackages: ["starship"],
    systemPackages: {
      pacman: ["starship"],
      dnf: [],
      apt: [],
      brew: ["starship"],
      winget: ["Starship.Starship"],
      curl: [
        {
          name: "starship",
          url: "https://starship.rs/install.sh",
          args: "-y",
          skipIf: "starship",
        },
      ],
    },
  },
  {
    id: "zsh",
    name: "Zsh",
    description: "Z shell with antidote plugin manager and custom config",
    category: "shell",
    core: false,
    onlyOn: UNIX_ONLY,
    stowPackages: ["zsh"],
    systemPackages: {
      pacman: ["zsh"],
      dnf: ["zsh"],
      apt: ["zsh"],
      brew: ["zsh"],
    },
    postInstall: [
      {
        description: "Install antidote plugin manager",
        command: `[ -d "\${ZDOTDIR:-$HOME}/.antidote" ] || git clone --depth=1 https://github.com/mattmc3/antidote.git "\${ZDOTDIR:-$HOME}/.antidote"`,
      },
    ],
    manualSteps: [
      "Create ~/.zshrc.local for machine-specific config (secrets, API tokens)",
    ],
  },

  // ─── Terminal ────────────────────────────────────────────────
  {
    id: "tmux",
    name: "Tmux",
    description: "Terminal multiplexer with catppuccin theme and custom keybinds",
    category: "terminal",
    core: true,
    onlyOn: UNIX_ONLY,
    stowPackages: ["tmux"],
    systemPackages: {
      pacman: ["tmux"],
      dnf: ["tmux"],
      apt: ["tmux"],
      brew: ["tmux"],
    },
    dirs: ["~/.config/tmux"],
    postInstall: [
      {
        description: "Install TPM (tmux plugin manager)",
        command: `[ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`,
      },
    ],
    manualSteps: [
      "Open tmux and press C-Space I to install plugins",
    ],
  },
  {
    id: "ghostty",
    name: "Ghostty",
    description: "GPU-accelerated terminal emulator with native platform integration",
    category: "terminal",
    core: true,
    stowPackages: ["ghostty"],
    systemPackages: {
      pacman: ["ghostty"],
    },
    dirs: ["~/.config/ghostty"],
  },

  // ─── Editor ──────────────────────────────────────────────────
  {
    id: "nvim",
    name: "Neovim",
    description: "Hyperextensible text editor with Lazy.nvim plugin management",
    category: "editor",
    core: true,
    stowPackages: ["nvim"],
    systemPackages: {
      pacman: ["neovim", "python-pynvim"],
      dnf: ["neovim"],
      apt: ["neovim"],
      brew: ["neovim"],
      winget: ["Neovim.Neovim"],
    },
    manualSteps: [
      "Open nvim to let Lazy.nvim auto-install plugins",
    ],
  },

  // ─── Appearance ──────────────────────────────────────────────
  {
    id: "bat",
    name: "Bat",
    description: "Cat clone with syntax highlighting and Catppuccin Mocha theme",
    category: "appearance",
    core: true,
    stowPackages: ["bat"],
    systemPackages: {
      pacman: ["bat"],
      dnf: ["bat"],
      apt: ["bat"],
      brew: ["bat"],
      winget: ["sharkdp.bat"],
    },
    dirs: ["~/.config/bat/themes"],
  },
  {
    id: "matugen",
    name: "Matugen",
    description: "Material You dynamic theming — auto-theme everything from wallpaper colors",
    category: "appearance",
    core: false,
    stowPackages: ["matugen"],
    systemPackages: {
      pacman: ["matugen"],
    },
    dependencies: ["hyprland"],
    onlyOn: ["arch"],
    dirs: ["~/.config/matugen", "~/.config/matugen/templates"],
    postInstall: [
      {
        description: "Remove stowed symlinks for matugen-managed configs",
        command: `for f in ~/.config/hypr/colors.conf ~/.config/quickshell/Core/Colors.qml ~/.config/mako/config ~/.config/hypr/hyprlock.conf ~/.config/ghostty/config ~/.config/fish/conf.d/theme.fish ~/.config/starship.toml; do [ -L "$f" ] && rm "$f"; done; true`,
        onlyOn: ["arch"],
      },
      {
        description: "Generate initial theme from current wallpaper",
        command: `WALLPAPER="$(swww query 2>/dev/null | head -1 | grep -oP 'image: \\K.*' || true)" && [ -z "$WALLPAPER" ] && WALLPAPER="$(find ~/.config/wallpapers -maxdepth 1 -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' \\) | head -1)" && [ -n "$WALLPAPER" ] && matugen image --source-color-index 0 "$WALLPAPER" || echo "No wallpaper found — run 'matugen image <path>' after adding wallpapers"`,
        onlyOn: ["arch"],
      },
    ],
    manualSteps: [
      "Change wallpaper via picker (ALT+W) to regenerate all colors",
      "Running nvim instances update live via SIGUSR1",
      "Run 'tmux source-file ~/.config/tmux/tmux.conf' to update active tmux sessions",
      "To revert: uninstall matugen module, then re-stow affected packages",
    ],
  },

  // ─── Dev Tools ───────────────────────────────────────────────
  {
    id: "git",
    name: "Git Config",
    description: "Git configuration with aliases, delta diff viewer, and global ignore",
    category: "dev-tools",
    core: true,
    stowPackages: ["git"],
    systemPackages: {
      pacman: ["git", "lazygit"],
      dnf: ["git"],
      apt: ["git"],
      brew: ["git", "lazygit"],
      winget: ["Git.Git", "JesseDuffield.lazygit"],
    },
    dirs: ["~/.config/git"],
    postInstall: [
      {
        description: "Set XDG_CONFIG_HOME for config path compatibility",
        command: '[Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$env:USERPROFILE\\.config", "User")',
        onlyOn: ["windows"],
      },
    ],
    manualSteps: [
      "Create ~/.gitconfig.local with [user] name and email",
    ],
  },
  {
    id: "claude",
    name: "Claude Code",
    description: "Claude AI CLI settings, hooks, and custom skills",
    category: "dev-tools",
    core: false,
    stowPackages: ["claude"],
    systemPackages: {},
    dirs: ["~/.claude/hooks", "~/.claude/skills"],
  },
  {
    id: "gh-dash",
    name: "GitHub Dashboard",
    description: "TUI dashboard for GitHub pull requests and issues",
    category: "dev-tools",
    core: false,
    stowPackages: ["gh-dash"],
    systemPackages: {
      pacman: ["github-cli"],
      dnf: [],
      brew: ["gh"],
      winget: ["GitHub.cli"],
    },
    dirs: ["~/.config/gh-dash"],
  },

  // ─── System ──────────────────────────────────────────────────
  {
    id: "fastfetch",
    name: "Fastfetch",
    description: "Fast system information tool written in C",
    category: "system",
    core: false,
    stowPackages: ["fastfetch"],
    systemPackages: {
      pacman: ["fastfetch"],
      dnf: ["fastfetch"],
      winget: ["Fastfetch-cli.Fastfetch"],
    },
  },
  {
    id: "neofetch",
    name: "Neofetch",
    description: "System information tool with ASCII art",
    category: "system",
    core: false,
    onlyOn: UNIX_ONLY,
    stowPackages: ["neofetch"],
    systemPackages: {
      pacman: ["neofetch"],
      dnf: [],
    },
    dirs: ["~/.config/neofetch"],
    conflicts: ["fastfetch"],
  },
  {
    id: "kanata",
    name: "Kanata",
    description: "Keyboard remapper — remap Caps Lock to Ctrl/Esc and more",
    category: "system",
    core: false,
    stowPackages: ["kanata"],
    systemPackages: {
      aur: ["kanata-bin"],
    },
    onlyOn: ["arch"],
    dirs: [
      "~/.config/kanata",
      "~/.config/systemd/user",
    ],
    postInstall: [
      {
        description: "Create uinput group for kanata",
        command: `getent group uinput &>/dev/null || sudo groupadd uinput`,
        sudo: true,
        onlyOn: ["arch"],
      },
      {
        description: "Add user to input/uinput groups",
        command: `sudo usermod -aG input,uinput "$USER"`,
        sudo: true,
        onlyOn: ["arch"],
      },
      {
        description: "Create uinput udev rule",
        command: `[ -f /etc/udev/rules.d/99-uinput.rules ] || echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-uinput.rules > /dev/null && sudo udevadm control --reload-rules && sudo udevadm trigger`,
        sudo: true,
        onlyOn: ["arch"],
      },
      {
        description: "Install and enable kanata systemd service",
        command: `cat > "$HOME/.config/systemd/user/kanata-laptop.service" <<'SVCEOF'
[Unit]
Description=kanata keyboard remapper (laptop built-in keyboard)
After=default.target

[Service]
ExecStart=/usr/bin/kanata --cfg %h/.config/kanata/laptop.kbd
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
SVCEOF
systemctl --user daemon-reload
systemctl --user enable --now kanata-laptop.service || true`,
        onlyOn: ["arch"],
      },
    ],
    manualSteps: [
      "Reboot for group changes to take effect",
      "Set kanata device: echo '/dev/input/by-path/...' > ~/.config/kanata/device.local",
    ],
  },

  // ─── Storage ────────────────────────────────────────────────
  {
    id: "network-storage",
    name: "Network Storage",
    description: "SMB mounts for Gondor — sync Documents/Music/Pictures/Videos, mount Media",
    category: "storage",
    core: false,
    stowPackages: ["network-storage"],
    systemPackages: {
      pacman: ["cifs-utils", "unison"],
    },
    dependencies: ["tailscale"],
    onlyOn: ["arch"],
    dirs: [
      "~/.config/network-storage",
      "~/.config/systemd/user",
      "~/.unison",
    ],
    configPrompts: [
      {
        label: "SMB server address (Tailscale hostname or IP)",
        default: "gondor",
        configFile: "~/.config/network-storage/config.env",
        configKey: "SMB_SERVER",
      },
      {
        label: "SMB username",
        default: "guest",
        configFile: "~/.config/network-storage/.smbcredentials",
        configKey: "username",
        createIfMissing: true,
      },
      {
        label: "SMB password (leave blank for guest)",
        default: "",
        configFile: "~/.config/network-storage/.smbcredentials",
        configKey: "password",
        secret: true,
        createIfMissing: true,
      },
    ],
    postInstall: [
      {
        description: "Run network storage setup",
        command: `bash "$HOME/.config/network-storage/setup.sh"`,
        sudo: true,
        onlyOn: ["arch"],
      },
    ],
    manualSteps: [
      "Edit ~/.config/network-storage/config.env to change server or sync settings",
      "Run 'unison network-storage' to manually sync documents",
    ],
  },

  // ─── Desktop (Arch/Hyprland) ─────────────────────────────────
  {
    id: "hyprland",
    name: "Hyprland",
    description: "Dynamic tiling Wayland compositor with animations and gestures",
    category: "desktop",
    core: false,
    stowPackages: ["hyprland"],
    systemPackages: {
      pacman: [
        "hyprland",
        "xdg-desktop-portal-hyprland",
        "swww",
        "wl-clipboard",
        "grim",
        "slurp",
        "qt5-wayland",
        "qt6-wayland",
        "brightnessctl",
        "playerctl",
        "pipewire",
        "wireplumber",
        "pavucontrol",
        "noto-fonts",
        "noto-fonts-emoji",
        "ttf-jetbrains-mono-nerd",
        "ttf-nerd-fonts-symbols",
      ],
    },
    onlyOn: ["arch"],
    dirs: [
      "~/.config/hypr",
      "~/.config/wallpapers",
      "~/Pictures/Screenshots",
      "~/.config/gtk-3.0",
      "~/.config/gtk-4.0",
    ],
    manualSteps: [
      "Add wallpapers to ~/.config/wallpapers/",
    ],
  },
  {
    id: "bluetui",
    name: "Bluetui",
    description: "TUI for managing Bluetooth devices — scan, pair, connect",
    category: "system",
    core: false,
    stowPackages: [],
    systemPackages: {
      pacman: ["bluetui", "bluez", "bluez-utils"],
    },
    onlyOn: ["arch"],
    postInstall: [
      {
        description: "Enable bluetooth service",
        command: "sudo systemctl enable --now bluetooth || true",
        sudo: true,
        onlyOn: ["arch"],
      },
    ],
  },
  {
    id: "tailscale",
    name: "Tailscale",
    description: "Mesh VPN with tsui TUI dashboard by Neuralink",
    category: "system",
    core: false,
    stowPackages: [],
    systemPackages: {
      pacman: ["tailscale"],
      aur: ["tsui"],
    },
    onlyOn: ["arch"],
    detectCommand: "systemctl is-enabled tailscaled",
    postInstall: [
      {
        description: "Enable tailscaled service",
        command: "sudo systemctl enable --now tailscaled || true",
        sudo: true,
        onlyOn: ["arch"],
      },
    ],
    manualSteps: [
      "Run 'sudo tailscale up' to authenticate",
    ],
  },
  {
    id: "quickshell",
    name: "Quickshell",
    description: "QML-based desktop shell — status bar, launcher, control center",
    category: "desktop",
    core: false,
    stowPackages: ["quickshell"],
    systemPackages: {
      pacman: ["qt6-declarative", "qt6-wayland", "imagemagick"],
      aur: ["quickshell-git"],
    },
    dependencies: ["hyprland"],
    onlyOn: ["arch"],
    dirs: ["~/.config/quickshell"],
  },
  {
    id: "mako",
    name: "Mako",
    description: "Lightweight Wayland notification daemon with Catppuccin theme",
    category: "desktop",
    core: false,
    stowPackages: ["mako"],
    systemPackages: {
      pacman: ["mako", "libnotify"],
    },
    dependencies: ["hyprland"],
    onlyOn: ["arch"],
    dirs: ["~/.config/mako"],
  },
  {
    id: "hyprlock",
    name: "Hyprlock + Hypridle",
    description: "Screen locker and idle daemon for Hyprland",
    category: "desktop",
    core: false,
    stowPackages: ["hyprlock", "hypridle"],
    systemPackages: {
      pacman: ["hyprlock", "hypridle"],
    },
    dependencies: ["hyprland"],
    onlyOn: ["arch"],
  },
  {
    id: "greetd",
    name: "Greetd + ReGreet",
    description: "Minimal login greeter with blurred wallpaper background",
    category: "desktop",
    core: false,
    stowPackages: ["greetd"],
    systemPackages: {
      pacman: ["greetd", "greetd-regreet"],
      aur: ["catppuccin-gtk-theme-mocha"],
    },
    dependencies: ["hyprland"],
    onlyOn: ["arch"],
    postInstall: [
      {
        description: "Install greeter configs to /etc/greetd/",
        command: `DOTFILES_DIR="$(cd "$(dirname "$(realpath "$0")")/../../.." && pwd)" &&
sudo install -Dm644 "$DOTFILES_DIR/greetd/etc/greetd/config.toml" /etc/greetd/config.toml &&
sudo install -Dm644 "$DOTFILES_DIR/greetd/etc/greetd/hyprland.conf" /etc/greetd/hyprland.conf &&
sudo install -Dm644 "$DOTFILES_DIR/greetd/etc/greetd/regreet.toml" /etc/greetd/regreet.toml &&
sudo install -Dm644 "$DOTFILES_DIR/greetd/etc/greetd/regreet.css" /etc/greetd/regreet.css &&
sudo chmod 755 /etc/greetd/`,
        sudo: true,
        onlyOn: ["arch"],
      },
      {
        description: "Generate blurred greeter wallpaper",
        command: `WALLPAPER="$(find "$HOME/.config/wallpapers" -maxdepth 1 -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' \\) | head -1)" &&
if [ -n "$WALLPAPER" ]; then
  convert "$WALLPAPER" -blur 0x24 -brightness-contrast -35 /tmp/greetd-wallpaper.jpg &&
  sudo install -Dm644 /tmp/greetd-wallpaper.jpg /etc/greetd/wallpaper.jpg &&
  rm -f /tmp/greetd-wallpaper.jpg
fi`,
        sudo: true,
        onlyOn: ["arch"],
      },
      {
        description: "Disable SDDM and enable greetd",
        command: `systemctl is-enabled sddm &>/dev/null && sudo systemctl disable sddm || true && sudo systemctl enable greetd`,
        sudo: true,
        onlyOn: ["arch"],
      },
    ],
    manualSteps: [
      "Reboot — greetd will start automatically",
      "Greeter fallback: Ctrl+Alt+F2 → TTY login → sudo systemctl disable greetd",
    ],
  },

  // ─── Social ──────────────────────────────────────────────────
  {
    id: "vesktop",
    name: "Vesktop",
    description: "Discord client with Vencord built-in and Catppuccin theme",
    category: "social",
    core: false,
    stowPackages: ["vesktop"],
    systemPackages: {
      aur: ["vesktop-bin"],
    },
    onlyOn: ["arch"],
    dirs: ["~/.config/vesktop/themes", "~/.config/vesktop/settings"],
  },
];

export function getModuleById(id: string): DotfilesModule | undefined {
  return modules.find((m) => m.id === id);
}

export function getModulesByCategory(category: string): DotfilesModule[] {
  return modules.filter((m) => m.category === category);
}

export function getCategories(): string[] {
  return [...new Set(modules.map((m) => m.category))];
}
