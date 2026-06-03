-- Matugen Material You theme — generated, do not edit
local base16 = require("base16-colorscheme")

base16.setup({
    base00 = "#1a1110",                  -- background
    base01 = "#271d1c",           -- lighter background (UI elements)
    base02 = "#322826",      -- selection
    base03 = "#534340",             -- comments
    base04 = "#a08c89",                     -- dark foreground
    base05 = "#f1dfdb",                  -- foreground
    base06 = "#d8c2be",          -- light foreground
    base07 = "#f1dfdb",                  -- lightest foreground
    base08 = "#ffb4ab",                       -- red (variables)
    base09 = "#ddc48c",                    -- orange (constants)
    base0A = "#fae0a6",       -- yellow (classes)
    base0B = "#ffb4a6",                     -- green (strings)
    base0C = "#e7bdb5",                   -- cyan (support)
    base0D = "#ffdad4",        -- blue (functions)
    base0E = "#ffdad4",      -- purple (keywords)
    base0F = "#ffdad6",          -- brown (deprecated)
})

-- Material You color palette
local c = {
    bg = "#1a1110",
    surface = "#1a1110",
    primary = "#ffb4a6",
    on_primary = "#561e15",
    secondary = "#e7bdb5",
    on_secondary = "#442a25",
    tertiary = "#ddc48c",
    error = "#ffb4ab",
    on_surface = "#f1dfdb",
    on_surface_variant = "#d8c2be",
    outline = "#a08c89",
    outline_variant = "#534340",
    surface_container_lowest = "#140c0b",
    surface_container_low = "#231918",
    surface_container = "#271d1c",
    surface_container_high = "#322826",
    surface_container_highest = "#3d3230",
    primary_container = "#733429",
    on_primary_container = "#ffdad4",
    secondary_container = "#5d3f3a",
    on_secondary_container = "#ffdad4",
    tertiary_container = "#564519",
    on_tertiary_container = "#fae0a6",
    error_container = "#93000a",
    on_error_container = "#ffdad6",
    inverse_surface = "#f1dfdb",
    inverse_on_surface = "#392e2c",
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
