-- lua/scaffold/config.lua  (Part 9)
-- Merge and validate user options.

local M = {}

-- Provided data: the defaults.
local DEFAULTS = { mode = 'cursor', keymap = '<leader>cg', command = 'Scaffold', bin = nil }

-- F-053  config.resolve(user: table|nil) -> table | nil, err
-- Merge the user's opts over the defaults and validate them. Defaults: mode='cursor', keymap='<leader>cg', command='Scaffold', bin=nil.
-- Requires: none
-- Produces: A new config table (the defaults are never mutated), or nil plus {code='bad_config', field, reason}.
-- Returns an error: bad_config opts: must be a table
-- Returns an error: bad_config mode: must be cursor, function or file
-- Returns an error: bad_config command: must start with an uppercase letter
-- Returns an error: bad_config bin: must be a string path
-- Tests: T-239, T-240, T-241, T-242, T-243, T-244, T-245, T-246   Diagram: AD-053   Part 9
-- Challenge: Calling resolve twice must not leak state: mutate the result, call again, and get fresh defaults.
function M.resolve(user)
  error('not implemented: F-053 config.resolve', 2)
end

return M
