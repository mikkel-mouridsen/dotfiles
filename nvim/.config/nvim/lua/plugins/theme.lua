return {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
        local generated = vim.fn.stdpath("config") .. "/lua/matugen-generated.lua"
        local f = io.open(generated, "r")
        if f then
            f:close()
            dofile(generated)
        else
            vim.cmd.colorscheme("base16-default-dark")
        end

        vim.api.nvim_create_autocmd("Signal", {
            pattern = "SIGUSR1",
            callback = function()
                local gf = io.open(generated, "r")
                if gf then
                    gf:close()
                    dofile(generated)
                end
            end,
        })
    end,
}
