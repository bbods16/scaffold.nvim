-- lua/scaffold/client.lua  (Part 9)
-- The ONLY place Lua talks to the OCaml engine (JSON over a child process).

local M = { bin = nil } -- bin: optional override of the engine path (set by init.setup)

-- F-054  client.binary() -> path | nil, err
-- Locate the engine executable: client.bin if set, else $SCAFFOLD_BIN, else <plugin root>/_build/default/bin/main.exe. Fail if it is not executable.
-- Requires: none
-- Produces: A path string, or nil plus {code='engine_missing', path, message}.
-- Returns an error: engine_missing
-- Editor/OS: debug.getinfo source path starts with @
-- Tests: T-247, T-248, T-249, T-250, T-251   Diagram: AD-054   Part 9
-- Challenge: Compute the plugin root without hard-coding a path, so the plugin works from lazy.nvim's install directory.
function M.binary()
  error('not implemented: F-054 client.binary', 2)
end

-- F-055  client.call(args: string[], stdin?: string) -> table | nil, err
-- Run the engine with args plus --json, wait for it, decode its stdout as JSON, and turn an {'error':...} reply into (nil, {code, message}).
-- Requires: none
-- Produces: The decoded JSON table on success.
-- Returns an error: engine_missing
-- Returns an error: engine_failed (could not start)
-- Returns an error: bad_json (stdout was not a JSON object)
-- Returns an error: the engine's own domain error code, e.g. unknown_lang
-- Tests: T-252, T-253, T-254, T-255, T-256, T-257, T-258, T-259, T-260   Diagram: AD-055   Part 9
-- Challenge: Include the child's stderr and exit code in the bad_json error, so a crashing engine can be diagnosed.
function M.call(args, stdin)
  error('not implemented: F-055 client.call', 2)
end

-- F-056  client.list(filetype: string) -> item[] | nil, err
-- The algorithms the engine offers for a Neovim filetype: a list of {id, title, group}.
-- Requires: none
-- Produces: A Lua array of items or (nil, err).
-- Returns an error: every client.call error, e.g. unknown_lang for an unmapped filetype
-- Tests: T-261, T-262, T-263   Diagram: AD-056   Part 9
-- Challenge: Do not rewrite the error.
function M.list(filetype)
  error('not implemented: F-056 client.list', 2)
end

-- F-057  client.prompts(filetype: string, algo: string) -> prompt[] | nil, err
-- The questions to ask for an algorithm: a list of {name, prompt, ghost}.
-- Requires: none
-- Produces: Array of prompts or (nil, err).
-- Returns an error: unknown_lang
-- Returns an error: unknown_algo
-- Tests: T-264, T-265, T-266, T-267   Diagram: AD-057   Part 9
-- Challenge: One more error path to test by hand: unknown algorithm.
function M.prompts(filetype, algo)
  error('not implemented: F-057 client.prompts', 2)
end

-- F-058  client.generate(req: {filetype, algo, answers?, mode?, indent?, text?}) -> {text, file?} | nil, err
-- Ask the engine to generate code. The buffer text goes to the engine on stdin (--scan -) so it can avoid name clashes; answers become repeated --set name=value.
-- Requires: none
-- Produces: {text=string, file=string|nil} or (nil, err).
-- Returns an error: every client.call error
-- Tests: T-268, T-269, T-270, T-271, T-272, T-273, T-274, T-275   Diagram: AD-058   Part 9
-- Challenge: data.file ~= vim.NIL and data.file or nil is the idiom; explain why plain data.file would be a bug.
function M.generate(req)
  error('not implemented: F-058 client.generate', 2)
end

return M
