set -gx BAT_THEME "Matugen"
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --color=bg+:{{colors.surface_container_high.default.hex}},bg:{{colors.background.default.hex}},spinner:{{colors.tertiary_fixed_dim.default.hex}},hl:{{colors.error.default.hex}},fg:{{colors.on_surface.default.hex}},header:{{colors.error.default.hex}},info:{{colors.primary.default.hex}},pointer:{{colors.tertiary_fixed_dim.default.hex}},marker:{{colors.secondary_fixed.default.hex}},fg+:{{colors.on_surface.default.hex}},prompt:{{colors.primary.default.hex}},hl+:{{colors.error.default.hex}},border:{{colors.outline_variant.default.hex}}"
if command -q vivid
    set -gx LS_COLORS (vivid generate catppuccin-mocha 2>/dev/null)
end
