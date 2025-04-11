require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")


-- Cmake Commnans
local opts = { noremap = true, silent = true }

map("n", "<leader>cb", ":CMakeBuild<CR>", vim.tbl_extend("force", opts, { desc = "Build" }))
map("n", "<leader>cr", ":CMakeRun<CR>", vim.tbl_extend("force", opts, { desc = "Run" }))
map("n", "<leader>cl", ":Telescope cmake select_target<CR>", vim.tbl_extend("force", opts, { desc = "Select Target" }))

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
