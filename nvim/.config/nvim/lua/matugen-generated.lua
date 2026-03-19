-- Matugen Material You theme — generated, do not edit
local base16 = require("base16-colorscheme")

base16.setup({
    base00 = "#1a1110",        -- background
    base01 = "#1a1110",            -- lighter background
    base02 = "#322826", -- selection
    base03 = "#534340",    -- comments
    base04 = "#a08c89",            -- dark foreground
    base05 = "#f1dfdb",         -- foreground
    base06 = "#d8c2be", -- light foreground
    base07 = "#f1dfdb",         -- lightest foreground
    base08 = "#ffb4ab",              -- red (variables)
    base09 = "#ddc48c",           -- orange (constants)
    base0A = "#564519", -- yellow (classes)
    base0B = "#ffb4a6",            -- green (strings)
    base0C = "#e7bdb5",          -- cyan (support)
    base0D = "#733429",  -- blue (functions)
    base0E = "#5d3f3a", -- purple (keywords)
    base0F = "#93000a",    -- brown (deprecated)
})

-- Custom highlight overrides
local c = {
    bg = "#1a1110",
    surface = "#1a1110",
    primary = "#ffb4a6",
    on_primary = "#561e15",
    secondary = "#e7bdb5",
    tertiary = "#ddc48c",
    error = "#ffb4ab",
    on_surface = "#f1dfdb",
    on_surface_variant = "#d8c2be",
    outline = "#a08c89",
    outline_variant = "#534340",
    surface_container = "#271d1c",
    surface_container_high = "#322826",
    primary_container = "#733429",
    on_primary_container = "#ffdad4",
    error_container = "#93000a",
    on_error_container = "#ffdad6",
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
