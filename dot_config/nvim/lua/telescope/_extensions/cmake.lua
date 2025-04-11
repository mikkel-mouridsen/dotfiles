local has_cmake, cmake = pcall(require, "cmake-tools")
if not has_cmake then
  vim.notify("[telescope-cmake] cmake-tools not loaded", vim.log.levels.ERROR)
  return
end

local Types = require("cmake-tools.types") -- Import Types
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

M.select_target = function()

  local config = cmake.get_config()
  -- Check if cmake.config is initialized
  if not config then
    vim.notify("[telescope-cmake] CMake configuration is not initialized.", vim.log.levels.ERROR)
    return
  end

  -- Get the launch targets from cmake-tools
  local targets_res = cmake.get_launch_targets()

  if targets_res.code ~= Types.SUCCESS then
    vim.notify("[telescope-cmake] Failed to get CMake targets", vim.log.levels.ERROR)
    return
  end

  local targets = targets_res.data.targets
  local display_targets = targets_res.data.display_targets

  local entries = {}
  for i, target in ipairs(display_targets) do
    table.insert(entries, {
      value = targets[i], -- The actual target name
      display = target,    -- The user-friendly display name
      ordinal = target,    -- Used for sorting
    })
  end

  -- Create the Telescope picker
  pickers.new({}, {
    prompt_title = 'Select CMake Launch Target',
    finder = finders.new_table {
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry.value,
          display = entry.display,
          ordinal = entry.ordinal,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, map)
      actions.select_default:replace(function(prompt_bufnr)
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Set the selected target as the current build target
          config.build_target = selection.value
          config.launch_target = selection.value
          vim.notify("CMake launch target selected: " .. selection.value)
        end
      end)
      return true
    end,
  }):find()
end

return require("telescope").register_extension({
  exports = {
    select_target = M.select_target,
  },
})
