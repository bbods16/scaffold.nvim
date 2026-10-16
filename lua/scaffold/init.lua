-- lua/scaffold/init.lua  (Part 10)
-- The single public entry point wired by LazyVim.

local config = require('scaffold.config')
local client = require('scaffold.client')
local buffer = require('scaffold.buffer')
local ui = require('scaffold.ui')
local commands = require('scaffold.commands')

local M = { _cfg = nil, _group = nil }

-- F-069  init.setup(opts?: table) -> M
-- Resolve config, remember it, point the client at cfg.bin, create the augroup, register the command and the pick keymap. Bad config is an error() naming the field.
-- Requires: none
-- Produces: the module table M (so setup can be chained).
-- Raises (exception/error): error('scaffold.setup: <field> <reason>') on bad config
-- Editor/OS: keymap/command creation
-- Tests: T-321, T-322, T-323, T-324, T-325   Diagram: AD-069   Part 10
-- Challenge: After setup({ bin = '/x' }), client.binary() must use '/x'.
function M.setup(opts)
  error('not implemented: F-069 init.setup', 2)
end

-- F-070  init.run(algo_id: string, mode?: string) -> nil
-- Run one insertion: read the buffer, fetch the prompts, ask each with ui.input (asynchronously), then generate and insert — as text, or as a new file that is written and opened. Any error is shown with vim.notify at ERROR level; cancelling (nil) stops silently.
-- Requires: setup has run (for the default mode)
-- Produces: nothing (effects only).
-- Returns an error: every error is reported through vim.notify, never raised
-- Tests: T-326, T-327, T-328, T-329, T-330, T-331, T-332, T-333   Diagram: AD-070   Part 10
-- Challenge: ui.input must be called through the module table (ui.input(...)), so tests can replace it.
function M.run(algo_id, mode)
  error('not implemented: F-070 init.run', 2)
end

-- F-071  init.pick() -> nil
-- Let the user choose an algorithm for the current filetype with vim.ui.select, then run it.
-- Requires: none
-- Produces: nothing.
-- Returns an error: errors shown with vim.notify
-- Tests: T-334, T-335, T-336, T-337   Diagram: AD-071   Part 10
-- Challenge: Notify, do not raise, for an unsupported filetype.
function M.pick()
  error('not implemented: F-071 init.pick', 2)
end

-- F-072  init.teardown() -> nil
-- Undo setup: delete the augroup, the user command and the keymap, forget the config and clear client.bin. Safe to call twice.
-- Requires: none
-- Produces: nothing.
-- Tests: T-338, T-339, T-340   Diagram: AD-072   Part 10
-- Challenge: Call it before any setup.
function M.teardown()
  error('not implemented: F-072 init.teardown', 2)
end

return M
