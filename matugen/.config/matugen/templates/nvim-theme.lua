-- Matugen Material You theme — generated, do not edit
local base16 = require("base16-colorscheme")

base16.setup({
    base00 = "{{colors.background.default.hex}}",                  -- background
    base01 = "{{colors.surface_container.default.hex}}",           -- lighter background (UI elements)
    base02 = "{{colors.surface_container_high.default.hex}}",      -- selection
    base03 = "{{colors.outline_variant.default.hex}}",             -- comments
    base04 = "{{colors.outline.default.hex}}",                     -- dark foreground
    base05 = "{{colors.on_surface.default.hex}}",                  -- foreground
    base06 = "{{colors.on_surface_variant.default.hex}}",          -- light foreground
    base07 = "{{colors.on_surface.default.hex}}",                  -- lightest foreground
    base08 = "{{colors.error.default.hex}}",                       -- red (variables)
    base09 = "{{colors.tertiary.default.hex}}",                    -- orange (constants)
    base0A = "{{colors.on_tertiary_container.default.hex}}",       -- yellow (classes)
    base0B = "{{colors.primary.default.hex}}",                     -- green (strings)
    base0C = "{{colors.secondary.default.hex}}",                   -- cyan (support)
    base0D = "{{colors.on_primary_container.default.hex}}",        -- blue (functions)
    base0E = "{{colors.on_secondary_container.default.hex}}",      -- purple (keywords)
    base0F = "{{colors.on_error_container.default.hex}}",          -- brown (deprecated)
})

-- Material You color palette
local c = {
    bg = "{{colors.background.default.hex}}",
    surface = "{{colors.surface.default.hex}}",
    primary = "{{colors.primary.default.hex}}",
    on_primary = "{{colors.on_primary.default.hex}}",
    secondary = "{{colors.secondary.default.hex}}",
    on_secondary = "{{colors.on_secondary.default.hex}}",
    tertiary = "{{colors.tertiary.default.hex}}",
    error = "{{colors.error.default.hex}}",
    on_surface = "{{colors.on_surface.default.hex}}",
    on_surface_variant = "{{colors.on_surface_variant.default.hex}}",
    outline = "{{colors.outline.default.hex}}",
    outline_variant = "{{colors.outline_variant.default.hex}}",
    surface_container_lowest = "{{colors.surface_container_lowest.default.hex}}",
    surface_container_low = "{{colors.surface_container_low.default.hex}}",
    surface_container = "{{colors.surface_container.default.hex}}",
    surface_container_high = "{{colors.surface_container_high.default.hex}}",
    surface_container_highest = "{{colors.surface_container_highest.default.hex}}",
    primary_container = "{{colors.primary_container.default.hex}}",
    on_primary_container = "{{colors.on_primary_container.default.hex}}",
    secondary_container = "{{colors.secondary_container.default.hex}}",
    on_secondary_container = "{{colors.on_secondary_container.default.hex}}",
    tertiary_container = "{{colors.tertiary_container.default.hex}}",
    on_tertiary_container = "{{colors.on_tertiary_container.default.hex}}",
    error_container = "{{colors.error_container.default.hex}}",
    on_error_container = "{{colors.on_error_container.default.hex}}",
    inverse_surface = "{{colors.inverse_surface.default.hex}}",
    inverse_on_surface = "{{colors.inverse_on_surface.default.hex}}",
}

local hi = vim.api.nvim_set_hl

-- Core UI
hi(0, "Visual", { bg = c.surface_container_high })
hi(0, "CursorLine", { bg = c.surface_container })
hi(0, "CursorLineNr", { fg = c.primary, bold = true })
hi(0, "LineNr", { fg = c.outline_variant })
hi(0, "SignColumn", { bg = "NONE" })
hi(0, "ColorColumn", { bg = c.surface_container })
hi(0, "WinSeparator", { fg = c.outline_variant })
hi(0, "StatusLine", { bg = c.surface_container, fg = c.on_surface })
hi(0, "StatusLineNC", { bg = c.surface_container_low, fg = c.outline })
hi(0, "TabLine", { bg = c.surface_container, fg = c.outline })
hi(0, "TabLineFill", { bg = c.surface_container_low })
hi(0, "TabLineSel", { bg = c.primary_container, fg = c.on_primary_container, bold = true })

-- Syntax
hi(0, "Comment", { fg = c.outline_variant, italic = true })

-- Search
hi(0, "Search", { bg = c.tertiary_container, fg = c.on_tertiary_container })
hi(0, "IncSearch", { bg = c.tertiary, fg = c.bg })
hi(0, "CurSearch", { bg = c.tertiary, fg = c.bg, bold = true })
hi(0, "MatchParen", { bg = c.surface_container_high, bold = true, underline = true })

-- Diagnostics
hi(0, "DiagnosticError", { fg = c.error })
hi(0, "DiagnosticWarn", { fg = c.tertiary })
hi(0, "DiagnosticInfo", { fg = c.primary })
hi(0, "DiagnosticHint", { fg = c.secondary })

-- Git signs
hi(0, "GitSignsAdd", { fg = c.primary })
hi(0, "GitSignsChange", { fg = c.tertiary })
hi(0, "GitSignsDelete", { fg = c.error })

-- Diff
hi(0, "DiffAdd", { bg = c.primary_container, fg = c.on_primary_container })
hi(0, "DiffChange", { bg = c.tertiary_container, fg = c.on_tertiary_container })
hi(0, "DiffDelete", { bg = c.error_container, fg = c.on_error_container })
hi(0, "DiffText", { bg = c.secondary_container, fg = c.on_secondary_container })

-- Floating windows
hi(0, "NormalFloat", { bg = c.surface_container })
hi(0, "FloatBorder", { fg = c.outline_variant })
hi(0, "Pmenu", { bg = c.surface_container, fg = c.on_surface })
hi(0, "PmenuSel", { bg = c.primary_container, fg = c.on_primary_container })

-- Telescope
hi(0, "TelescopeBorder", { fg = c.outline_variant })

-- Bufferline
hi(0, "BufferLineBackground", { bg = c.surface_container_low, fg = c.outline })
hi(0, "BufferLineBuffer", { bg = c.surface_container_low, fg = c.outline })
hi(0, "BufferLineBufferSelected", { bg = c.bg, fg = c.on_surface, bold = true })
hi(0, "BufferLineBufferVisible", { bg = c.surface_container_low, fg = c.outline })
hi(0, "BufferLineFill", { bg = c.surface_container_lowest })
hi(0, "BufferLineTab", { bg = c.surface_container_low, fg = c.outline })
hi(0, "BufferLineTabSelected", { bg = c.bg, fg = c.primary, bold = true })
hi(0, "BufferLineTabClose", { bg = c.surface_container_low, fg = c.outline })
hi(0, "BufferLineModified", { fg = c.tertiary })
hi(0, "BufferLineModifiedSelected", { fg = c.tertiary })
hi(0, "BufferLineIndicatorSelected", { fg = c.primary })

-- Neo-tree
hi(0, "NeoTreeNormal", { bg = c.surface_container_low, fg = c.on_surface })
hi(0, "NeoTreeNormalNC", { bg = c.surface_container_low, fg = c.on_surface })
hi(0, "NeoTreeDirectoryName", { fg = c.primary })
hi(0, "NeoTreeDirectoryIcon", { fg = c.primary })
hi(0, "NeoTreeRootName", { fg = c.primary, bold = true })
hi(0, "NeoTreeGitModified", { fg = c.tertiary })
hi(0, "NeoTreeGitAdded", { fg = c.primary })
hi(0, "NeoTreeGitDeleted", { fg = c.error })
hi(0, "NeoTreeIndentMarker", { fg = c.outline_variant })
hi(0, "NeoTreeWinSeparator", { fg = c.outline_variant, bg = c.surface_container_low })

-- Which-key
hi(0, "WhichKey", { fg = c.primary })
hi(0, "WhichKeyGroup", { fg = c.secondary })
hi(0, "WhichKeyDesc", { fg = c.on_surface })
hi(0, "WhichKeyBorder", { fg = c.outline_variant })
hi(0, "WhichKeySeparator", { fg = c.outline_variant })
hi(0, "WhichKeyValue", { fg = c.outline })

-- Noice
hi(0, "NoiceCmdlinePopup", { bg = c.surface_container })
hi(0, "NoiceCmdlinePopupBorder", { fg = c.outline_variant })
hi(0, "NoiceCmdlineIcon", { fg = c.primary })
hi(0, "NoiceConfirm", { bg = c.surface_container })
hi(0, "NoiceConfirmBorder", { fg = c.primary })
hi(0, "NoiceMini", { bg = c.surface_container })

-- Flash.nvim
hi(0, "FlashLabel", { bg = c.primary, fg = c.on_primary, bold = true })
hi(0, "FlashMatch", { bg = c.tertiary_container, fg = c.on_tertiary_container })
hi(0, "FlashCurrent", { bg = c.secondary_container, fg = c.on_secondary_container })

-- Mini.indentscope
hi(0, "MiniIndentscopeSymbol", { fg = c.outline_variant })

-- Lazy.nvim UI
hi(0, "LazyH1", { bg = c.primary, fg = c.on_primary, bold = true })
hi(0, "LazyButton", { bg = c.surface_container_high, fg = c.on_surface })
hi(0, "LazyButtonActive", { bg = c.primary_container, fg = c.on_primary_container, bold = true })
hi(0, "LazySpecial", { fg = c.tertiary })

-- Treesitter overrides
hi(0, "@keyword", { fg = c.on_secondary_container })
hi(0, "@function", { fg = c.on_primary_container })
hi(0, "@function.call", { fg = c.on_primary_container })
hi(0, "@type", { fg = c.on_tertiary_container })
hi(0, "@string", { fg = c.primary })
hi(0, "@variable", { fg = c.on_surface })
hi(0, "@constant", { fg = c.tertiary })
hi(0, "@property", { fg = c.secondary })
hi(0, "@parameter", { fg = c.on_surface_variant })
hi(0, "@punctuation", { fg = c.outline })
hi(0, "@operator", { fg = c.outline })
hi(0, "@comment", { fg = c.outline_variant, italic = true })

return c
