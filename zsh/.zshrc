# ── PATH ─────────────────────────────────────────────────────────
if [[ -d /opt/homebrew ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/opt/openjdk/bin:$PATH"
fi
export PATH="$HOME/.local/bin:$PATH"

# ── Auto-enter distrobox (Linux host only) ───────────────────────
if command -v distrobox &>/dev/null && [[ ! -f /run/.containerenv ]]; then
  exec distrobox enter dev -- zsh
fi

# ── Auto-start tmux ──────────────────────────────────────────────
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  tmux new-session -A -s main
fi

# ── Antidote (plugin manager) ────────────────────────────────────
if [[ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]]; then
  source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
elif [[ -f /usr/share/zsh-antidote/antidote.zsh ]]; then
  source /usr/share/zsh-antidote/antidote.zsh
elif [[ -f ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh ]]; then
  source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
fi
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# ── Completion system ────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── History ──────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ── Starship prompt ──────────────────────────────────────────────
eval "$(starship init zsh)"

# ── vivid (LS_COLORS) ───────────────────────────────────────────
if command -v vivid &>/dev/null; then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
fi

# ── bat ──────────────────────────────────────────────────────────
export BAT_THEME="Catppuccin-Mocha"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── fzf ──────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --color=selected-bg:#45475a \
  --border rounded --margin 1 --padding 1"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || ls -la {}'"
export FZF_ALT_C_OPTS="--preview 'ls -la {} | head -20'"

# ── Aliases ──────────────────────────────────────────────────────
alias l="ls -lah --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias cls="clear"
alias lg="lazygit"
alias v="nvim"

# ── Yazi shell wrapper ───────────────────────────────────────────
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ── Zoxide (smart cd) ────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Machine-specific overrides ───────────────────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
