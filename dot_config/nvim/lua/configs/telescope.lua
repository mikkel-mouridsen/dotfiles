local chad_telescope = require("nvchad.configs.telescope")  -- Load NvChad defaults
local telescope = require("telescope")

telescope.setup(vim.tbl_deep_extend("force", chad_telescope, {
  extensions = {
    cmake = {},
  },
  defualts = {
    mappings = {
      i = {
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
      },
      n = {
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
      },
    },
  },
}))

-- require("telescope").load_extension("cmake")
