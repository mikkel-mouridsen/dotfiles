# 🛠️ My Dotfiles

Personal macOS dotfiles to keep my development environment clean, keyboard-driven, and beautiful.

Managed with [`chezmoi`](https://www.chezmoi.io/), and built around a minimal tiling workflow with modern tooling.

## ✨ Features

- 🧱 **Aerospace** – Tiling window manager for macOS  
- 🎨 **Sketchybar** – Highly customizable status bar  
- 🔧 **NeoVim** – Powered by [NvChad](https://nvchad.com/) + Lazy plugin manager  
- 📟 **tmux** – Terminal multiplexing, tightly integrated with `nvim`  
- 🐱‍💻 **Kitty** – Fast, GPU-based terminal emulator

## ⚙️ Setup

> Prerequisites: macOS + Git + Homebrew + chezmoi

### 1. Install `chezmoi`

```bash
brew install chezmoi
```

### 2. Initialize dotfiles

```bash
chezmoi init <github_username> --apply
```
