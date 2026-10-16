-- lua/scaffold/commands.lua  (Part 10)
-- User command, argument parsing and completion.

local client = require('scaffold.client')
local M = {}

-- F-066  commands.parse_args(fargs: string[]) -> {algo, mode?} | nil, err
-- Turn the command's words into {algo, mode}. The first word is the algorithm id; later words must be mode=<value>.
-- Requires: at least one word (guaranteed by nargs='+')
-- Produces: A table or (nil, {code='bad_arg', arg}).
-- Returns an error: bad_arg
-- Tests: T-305, T-306, T-307, T-308, T-309, T-310   Diagram: AD-066   Part 10
-- Challenge: mode= (empty) and colour=red are both bad_arg.
function M.parse_args(fargs)
  error('not implemented: F-066 commands.parse_args', 2)
end

-- F-067  commands.complete(arglead: string, cmdline: string) -> string[]
-- Command-line completion: the first argument completes to algorithm ids for the current buffer's filetype; later arguments complete to mode=cursor|function|file.
-- Requires: none
-- Produces: A list of candidate strings (possibly empty).
-- Tests: T-311, T-312, T-313, T-314, T-315, T-316   Diagram: AD-067   Part 10
-- Challenge: No error escapes when the filetype is unknown or the binary is missing.
function M.complete(arglead, cmdline)
  error('not implemented: F-067 commands.complete', 2)
end

-- F-068  commands.register(name: string, handler: fun(args)) -> nil
-- Create the user command name (nargs='+', with completion). It parses its arguments; on bad arguments it notifies an error, otherwise it calls handler(args).
-- Requires: none
-- Produces: nothing.
-- Editor/OS: Neovim rejects command names not starting with an uppercase letter
-- Tests: T-317, T-318, T-319, T-320   Diagram: AD-068   Part 10
-- Challenge: Notify Scaffold: <code> and do not call handler on bad args.
function M.register(name, handler)
  error('not implemented: F-068 commands.register', 2)
end

return M
