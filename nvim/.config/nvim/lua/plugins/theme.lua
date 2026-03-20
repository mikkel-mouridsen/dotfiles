local generated = vim.fn.stdpath("config") .. "/lua/matugen-generated.lua"

local function load_generated()
    local f = io.open(generated, "r")
    if f then
        f:close()
        return dofile(generated)
    end
    return nil
end

local function matugen_lualine_theme(colors)
    return {
        normal = {
            a = { bg = colors.primary, fg = colors.on_primary, gui = "bold" },
            b = { bg = colors.surface_container, fg = colors.on_surface },
            c = { bg = colors.surface_container_low, fg = colors.on_surface_variant },
        },
        insert = {
            a = { bg = colors.tertiary, fg = colors.bg, gui = "bold" },
        },
        visual = {
            a = { bg = colors.secondary, fg = colors.on_secondary, gui = "bold" },
        },
        replace = {
            a = { bg = colors.error, fg = colors.bg, gui = "bold" },
        },
        command = {
            a = { bg = colors.on_primary_container, fg = colors.bg, gui = "bold" },
        },
        inactive = {
            a = { bg = colors.surface_container_low, fg = colors.outline },
            b = { bg = colors.surface_container_low, fg = colors.outline },
            c = { bg = colors.surface_container_low, fg = colors.outline },
        },
    }
end

return {
    -- Base16 theme with matugen Material You colors
    {
        "RRethy/base16-nvim",
        lazy = false,
        priority = 1000,
        config = function()
            local colors = load_generated()
            if not colors then
                vim.cmd.colorscheme("base16-default-dark")
            end

            vim.api.nvim_create_autocmd("Signal", {
                pattern = "SIGUSR1",
                callback = function()
                    local c = load_generated()
                    if c then
                        local ok, lualine = pcall(require, "lualine")
                        if ok then
                            lualine.setup({ options = { theme = matugen_lualine_theme(c) } })
                        end
                    end
                end,
            })
        end,
    },

    -- Lualine theme using matugen colors
    {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
            local colors = load_generated()
            if colors then
                opts.options = opts.options or {}
                opts.options.theme = matugen_lualine_theme(colors)
            end
        end,
    },
}
