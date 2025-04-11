return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "Civitasv/cmake-tools.nvim",
    config = function()
      require "configs.cmake"
    end,
    ft = { "cpp", "c", "cmake" },
    cmd = { "CMakeGenerate", "CMakeBuild", "CMakeRun", "CMakeSelectBuildTarget", "CMakeSelectLaunchTarget" },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("configs.telescope")
    end,
  },

  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim"
    },
  },

  {
    "github/copilot.vim",
    lazy = false,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
