-- lua_test/run.lua  -- PROVIDED.  Run from the project root:
--   nvim --headless -u NONE -l lua_test/run.lua
-- Optional argument: one module name, e.g.  nvim --headless -u NONE -l lua_test/run.lua buffer
-- Optional argument: one module name, e.g.  nvim --headless -u NONE -l lua_test/run.lua buffer
-- Optional argument: one module name, e.g.  nvim --headless -u NONE -l lua_test/run.lua buffer
-- Optional argument: one module name, e.g.  nvim --headless -u NONE -l lua_test/run.lua buffer
-- Optional argument: one module name, e.g.  nvim --headless -u NONE -l lua_test/run.lua buffer
-- Optional argument: one module name, e.g.  nvim --headless -u NONE -l lua_test/run.lua buffer
-- Needs Neovim 0.10+ and a built engine (`dune build`).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = table.concat({ root .. "/lua/?.lua", root .. "/lua/?/init.lua", root .. "/?.lua", package.path }, ";")
vim.opt.runtimepath:prepend(root)
vim.cmd("cd " .. vim.fn.fnameescape(root))
local H = require("lua_test.harness")
local only = arg and arg[1]
local pattern = only and (root .. "/lua_test/" .. only .. "_spec.lua") or (root .. "/lua_test/*_spec.lua")
local specs = vim.fn.sort(vim.fn.glob(pattern, false, true))
for _, f in ipairs(specs) do dofile(f) end
local failed = H.run()
os.exit(failed == 0 and 0 or 1)
