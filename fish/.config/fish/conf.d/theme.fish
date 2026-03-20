set -gx BAT_THEME "Matugen"
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --color=bg+:#322826,bg:#1a1110,spinner:#ddc48c,hl:#ffb4ab,fg:#f1dfdb,header:#ffb4ab,info:#ffb4a6,pointer:#ddc48c,marker:#ffdad4,fg+:#f1dfdb,prompt:#ffb4a6,hl+:#ffb4ab,border:#534340"
if command -q vivid
    set -gx LS_COLORS (vivid generate catppuccin-mocha 2>/dev/null)
end
