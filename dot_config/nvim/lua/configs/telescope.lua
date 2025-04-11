local chad_telescope = require("nvchad.configs.telescope")  -- Load NvChad defaults
local telescope = require("telescope")

telescope.setup(vim.tbl_deep_extend("force", chad_telescope, {
  extensions = {
    cmake = {},
  },
}))

-- require("telescope").load_extension("cmake")
