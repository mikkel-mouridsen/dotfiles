# ── Navigation ───────────────────────────────────────────────────
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'

# ── ls / eza ─────────────────────────────────────────────────────
if command -q eza
    abbr --add ls 'eza --icons'
    abbr --add ll 'eza -lah --icons --git'
    abbr --add lt 'eza --tree --icons -L 2'
else
    abbr --add ll 'ls -lah'
end

# ── Git ──────────────────────────────────────────────────────────
abbr --add g git
abbr --add gs 'git status'
abbr --add gd 'git diff'
abbr --add ga 'git add'
abbr --add gc 'git commit'
abbr --add gp 'git push'
abbr --add gl 'git log --oneline --graph'

# ── Neovim ───────────────────────────────────────────────────────
abbr --add v nvim
abbr --add vi nvim
abbr --add vim nvim

# ── Misc ─────────────────────────────────────────────────────────
abbr --add lg lazygit
abbr --add cat bat
