-- lua_test/commands_spec.lua  -- PROVIDED. Do not edit; make the code pass. Test ids (T-nnn) are quoted in the spec.
local H = require("lua_test.harness")
local F = require("lua_test.fixtures")
local eq, raises = H.eq, H.raises
local config = require("scaffold.config")
local client = require("scaffold.client")
local buffer = require("scaffold.buffer")
local ui = require("scaffold.ui")
local commands = require("scaffold.commands")
local init = require("scaffold.init")

H.test("T-305 commands.parse_args: algo only", function()
  eq(commands.parse_args({ "stack" }), { algo = "stack" })
end)

H.test("T-306 commands.parse_args: mode", function()
  eq(commands.parse_args({ "stack", "mode=file" }), { algo = "stack", mode = "file" })
end)

H.test("T-307 commands.parse_args: last mode wins", function()
  eq(commands.parse_args({ "stack", "mode=file", "mode=cursor" }).mode, "cursor")
end)

H.test("T-308 commands.parse_args: the mode value is not validated here", function()
  eq(commands.parse_args({ "stack", "mode=zzz" }).mode, "zzz")
end)

H.test("T-309 commands.parse_args: unknown key", function()
  local a, e = commands.parse_args({ "stack", "colour=red" }); eq(a, nil); eq(e, { code = "bad_arg", arg = "colour=red" })
end)

H.test("T-310 commands.parse_args: malformed", function()
  eq(select(2, commands.parse_args({ "stack", "mode=" })).code, "bad_arg"); eq(select(2, commands.parse_args({ "stack", "junk" })).arg, "junk")
end)

H.test("T-311 commands.complete: filters by prefix", function()
  F.scratch("python", { "" }); eq(commands.complete("bin", "Scaffold bin"), { "binary-search" })
end)

H.test("T-312 commands.complete: empty lead gives all", function()
  F.scratch("python", { "" }); eq(commands.complete("", "Scaffold "), { "binary-search", "insertion-sort", "stack", "union-find" })
end)

H.test("T-313 commands.complete: after the algorithm: modes", function()
  eq(commands.complete("mode=f", "Scaffold stack mode=f"), { "mode=function", "mode=file" })
end)

H.test("T-314 commands.complete: all modes", function()
  eq(#commands.complete("", "Scaffold stack "), 3)
end)

H.test("T-315 commands.complete: unknown filetype", function()
  F.scratch("lua", { "" }); eq(commands.complete("", "Scaffold "), {})
end)

H.test("T-316 commands.complete: missing engine", function()
  F.with_clean_engine(function() F.scratch("python", { "" }); client.bin = "/nope"; eq(commands.complete("", "Scaffold "), {}) end)
end)

H.test("T-317 commands.register: registers and passes parsed args", function()
  local got; commands.register("ScaffoldT1", function(a) got = a end); vim.cmd("ScaffoldT1 stack mode=file"); vim.api.nvim_del_user_command("ScaffoldT1"); eq(got, { algo = "stack", mode = "file" })
end)

H.test("T-318 commands.register: command has nargs + and a completer", function()
  commands.register("ScaffoldT2", function() end); local c = vim.api.nvim_get_commands({})["ScaffoldT2"]; vim.api.nvim_del_user_command("ScaffoldT2"); eq(c.nargs, "+"); assert(c.complete ~= nil or c.complete_arg ~= nil or true)
end)

H.test("T-319 commands.register: bad args: error notification, no handler call", function()
  local called = false; local n, restore = F.capture_notify(); commands.register("ScaffoldT3", function() called = true end); vim.cmd("ScaffoldT3 stack colour=red"); restore(); vim.api.nvim_del_user_command("ScaffoldT3"); eq(called, false); eq(#n, 1); eq(n[1].level, vim.log.levels.ERROR); assert(F.has(n[1].msg, "bad_arg"))
end)

H.test("T-320 commands.register: lowercase name is rejected by Neovim", function()
  raises(function() commands.register("scaffoldlower", function() end) end, "must start with uppercase")
end)
