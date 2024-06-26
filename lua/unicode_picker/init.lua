local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local themes = require("telescope.themes")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

M.unicode_chars = function(opts)
	local initial_mode = vim.api.nvim_get_mode()
	opts = opts or themes.get_cursor()
	local chars = require("unicode_picker.chars")
	return pickers
		.new(opts, {
			prompt_title = "Pick a unicode character",
			finder = finders.new_table({
				results = chars(),
				entry_maker = function(entry)
					return {
						value = entry,
						display = "[" .. entry[1] .. "]: " .. table.concat(entry, " ", 2),
						ordinal = table.concat(entry, " ", 2),
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry().value
					-- Return to insert mode if we started there
					if initial_mode.mode == "i" then
						vim.api.nvim_feedkeys("a", "i", false)
					end

					vim.api.nvim_put({ selection[1] }, "c", false, true)
				end)
				return true
			end,
		})
		:find()
end

return M
