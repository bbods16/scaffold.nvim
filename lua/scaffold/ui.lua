-- lua/scaffold/ui.lua  (Part 10)
-- Ghost text (extmarks) and the floating one-line input.

local M = {}

-- Provided: the namespace for ghost text (created once; same name = same id).
local ns = vim.api.nvim_create_namespace('scaffold_ghost')

-- F-063  ui.ghost_set(bufnr: integer, row: integer, text: string) -> extmark_id | nil, err
-- Show grey 'ghost' text at the end of line row (1-based) using a virtual-text extmark in the plugin's own namespace.
-- Requires: none
-- Produces: The extmark id (an integer), or (nil, invalid_buffer).
-- Returns an error: invalid_buffer
-- Tests: T-293, T-294, T-295   Diagram: AD-063   Part 10
-- Challenge: Create the namespace once, not on every call.
function M.ghost_set(bufnr, row, text)
  error('not implemented: F-063 ui.ghost_set', 2)
end

-- F-064  ui.ghost_clear(bufnr: integer) -> nil
-- Remove every ghost extmark of this plugin from the buffer. Silent for invalid buffers.
-- Requires: none
-- Produces: nothing.
-- Tests: T-296, T-297   Diagram: AD-064   Part 10
-- Challenge: Never raise.
function M.ghost_clear(bufnr)
  error('not implemented: F-064 ui.ghost_clear', 2)
end

-- F-065  ui.input(prompt: string, ghost: string, on_done: fun(value: string|nil)) -> handle {close, buf, win}
-- Open a one-line floating window titled with the prompt, show the ghost text, and call on_done(line) on <CR> or on_done(nil) on <Esc>. on_done runs exactly once, asynchronously (vim.schedule), after the window is closed.
-- Requires: none
-- Produces: A handle table {close=function(value), buf, win}.
-- Raises (exception/error): error() if on_done is not a function
-- Editor/OS: nvim_open_win config: relative, width, height, row, col, style, border, title
-- Tests: T-298, T-299, T-300, T-301, T-302, T-303, T-304   Diagram: AD-065   Part 10
-- Challenge: Pressing <Esc> twice, or <CR> after <Esc>, must call on_done only once.
function M.input(prompt, ghost, on_done)
  error('not implemented: F-065 ui.input', 2)
end

return M
