-- lua/scaffold/buffer.lua  (Part 9)
-- The only module that reads/writes buffers and files. nvim_buf_set_lines is 0-based and end-EXCLUSIVE.

local M = {}

-- F-059  buffer.context(bufnr: integer) -> ctx | nil, err
-- Read what the engine needs from a buffer: filetype, cursor row (1-based), indentation of the cursor line, the full text, and the file name.
-- Requires: bufnr is shown in the current window (the cursor belongs to the window)
-- Produces: {filetype, row, indent, text, name} or (nil, {code='invalid_buffer', bufnr}).
-- Returns an error: invalid_buffer
-- Editor/OS: nvim_win_get_cursor(0) reads the CURRENT window, not bufnr's
-- Tests: T-276, T-277, T-278, T-279, T-280   Diagram: AD-059   Part 9
-- Challenge: Handle a cursor line that is empty or nil without crashing.
function M.context(bufnr)
  error('not implemented: F-059 buffer.context', 2)
end

-- F-060  buffer.insert_lines(bufnr: integer, row: integer, text: string) -> true | nil, err
-- Insert text (which may span several lines) AFTER line row (1-based; row 0 inserts at the top).
-- Requires: none
-- Produces: true, or (nil, err).
-- Returns an error: invalid_buffer
-- Returns an error: api_error (row out of range)
-- Editor/OS: strict_indexing = true makes out-of-range rows errors
-- Tests: T-281, T-282, T-283, T-284, T-285, T-286   Diagram: AD-060   Part 9
-- Challenge: Row = number of lines is legal (append at the end); row beyond that is an api_error.
function M.insert_lines(bufnr, row, text)
  error('not implemented: F-060 buffer.insert_lines', 2)
end

-- F-061  buffer.write_file(path: string, text: string) -> true | nil, err
-- Create a new file containing the text; refuse to overwrite an existing path.
-- Requires: none
-- Produces: true, or (nil, {code='file_exists', path}) / (nil, {code='api_error', message}).
-- Returns an error: file_exists
-- Returns an error: api_error
-- Editor/OS: vim.fn.writefile raises for an unwritable path
-- Tests: T-287, T-288, T-289   Diagram: AD-061   Part 9
-- Challenge: Report the path in the file_exists error.
function M.write_file(path, text)
  error('not implemented: F-061 buffer.write_file', 2)
end

-- F-062  buffer.open_file(path: string) -> bufnr | nil, err
-- Open a file in the current window and return its buffer number.
-- Requires: none
-- Produces: A buffer number, or (nil, api_error).
-- Returns an error: api_error
-- Tests: T-290, T-291, T-292   Diagram: AD-062   Part 9
-- Challenge: A path with spaces must work.
function M.open_file(path)
  error('not implemented: F-062 buffer.open_file', 2)
end

return M
