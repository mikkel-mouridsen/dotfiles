-- Matugen Material You theme — generated, do not edit
local base16 = require("base16-colorscheme")

base16.setup({
    base00 = "{{colors.background.default.hex}}",        -- background
    base01 = "{{colors.surface.default.hex}}",            -- lighter background
    base02 = "{{colors.surface_container_high.default.hex}}", -- selection
    base03 = "{{colors.outline_variant.default.hex}}",    -- comments
    base04 = "{{colors.outline.default.hex}}",            -- dark foreground
    base05 = "{{colors.on_surface.default.hex}}",         -- foreground
    base06 = "{{colors.on_surface_variant.default.hex}}", -- light foreground
    base07 = "{{colors.on_surface.default.hex}}",         -- lightest foreground
    base08 = "{{colors.error.default.hex}}",              -- red (variables)
    base09 = "{{colors.tertiary.default.hex}}",           -- orange (constants)
    base0A = "{{colors.tertiary_container.default.hex}}", -- yellow (classes)
    base0B = "{{colors.primary.default.hex}}",            -- green (strings)
    base0C = "{{colors.secondary.default.hex}}",          -- cyan (support)
    base0D = "{{colors.primary_container.default.hex}}",  -- blue (functions)
    base0E = "{{colors.secondary_container.default.hex}}", -- purple (keywords)
    base0F = "{{colors.error_container.default.hex}}",    -- brown (deprecated)
})

-- Custom highlight overrides
local c = {
    bg = "{{colors.background.default.hex}}",
    surface = "{{colors.surface.default.hex}}",
    primary = "{{colors.primary.default.hex}}",
    on_primary = "{{colors.on_primary.default.hex}}",
    secondary = "{{colors.secondary.default.hex}}",
    tertiary = "{{colors.tertiary.default.hex}}",
    error = "{{colors.error.default.hex}}",
    on_surface = "{{colors.on_surface.default.hex}}",
    on_surface_variant = "{{colors.on_surface_variant.default.hex}}",
    outline = "{{colors.outline.default.hex}}",
    outline_variant = "{{colors.outline_variant.default.hex}}",
    surface_container = "{{colors.surface_container.default.hex}}",
    surface_container_high = "{{colors.surface_container_high.default.hex}}",
    primary_container = "{{colors.primary_container.default.hex}}",
    on_primary_container = "{{colors.on_primary_container.default.hex}}",
    error_container = "{{colors.error_container.default.hex}}",
    on_error_container = "{{colors.on_error_container.default.hex}}",
}

local hi = vim.api.nvim_set_hl
hi(0, "Visual", { bg = c.surface_container_high })
hi(0, "CursorLine", { bg = c.surface })
hi(0, "Comment", { fg = c.outline_variant, italic = true })
hi(0, "DiagnosticError", { fg = c.error })
hi(0, "DiagnosticWarn", { fg = c.tertiary })
hi(0, "DiagnosticInfo", { fg = c.primary })
hi(0, "DiagnosticHint", { fg = c.secondary })
hi(0, "GitSignsAdd", { fg = c.primary })
hi(0, "GitSignsChange", { fg = c.tertiary })
hi(0, "GitSignsDelete", { fg = c.error })
hi(0, "TelescopeBorder", { fg = c.outline_variant })
hi(0, "FloatBorder", { fg = c.outline_variant })
hi(0, "NormalFloat", { bg = c.surface_container })
hi(0, "Pmenu", { bg = c.surface_container, fg = c.on_surface })
hi(0, "PmenuSel", { bg = c.primary_container, fg = c.on_primary_container })
