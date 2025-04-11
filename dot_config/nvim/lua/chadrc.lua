-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

local ascii = require("ascii")

M.base46 = {
	theme = "catppuccin",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.nvdash = { 
  load_on_startup = true,
  header = ascii.get_random_global(),
}
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}

return M
