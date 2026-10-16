-- lua_test/config_spec.lua  -- PROVIDED. Do not edit; make the code pass. Test ids (T-nnn) are quoted in the spec.
local H = require("lua_test.harness")
local F = require("lua_test.fixtures")
local eq, raises = H.eq, H.raises
local config = require("scaffold.config")
local client = require("scaffold.client")
local buffer = require("scaffold.buffer")
local ui = require("scaffold.ui")
local commands = require("scaffold.commands")
local init = require("scaffold.init")

H.test("T-239 config.resolve: nil gives defaults", function()
  local c = config.resolve(nil); eq(c.mode, "cursor"); eq(c.keymap, "<leader>cg"); eq(c.command, "Scaffold"); eq(c.bin, nil)
end)

H.test("T-240 config.resolve: user values override", function()
  local c = config.resolve({ mode = "file", keymap = "<leader>x", bin = "/opt/engine" }); eq(c.mode, "file"); eq(c.keymap, "<leader>x"); eq(c.bin, "/opt/engine")
end)

H.test("T-241 config.resolve: unknown keys survive", function()
  eq(config.resolve({ extra = 1 }).extra, 1)
end)

H.test("T-242 config.resolve: defaults are not shared between calls", function()
  local a = config.resolve(nil); a.mode = "file"; eq(config.resolve(nil).mode, "cursor")
end)

H.test("T-243 config.resolve: opts must be a table", function()
  local c, e = config.resolve("x"); eq(c, nil); eq(e, { code = "bad_config", field = "opts", reason = "must be a table" })
end)

H.test("T-244 config.resolve: bad mode", function()
  local c, e = config.resolve({ mode = "bottom" }); eq(c, nil); eq(e.field, "mode"); eq(e.code, "bad_config")
end)

H.test("T-245 config.resolve: command capitalisation and type", function()
  eq(select(2, config.resolve({ command = "scaffold" })).field, "command"); eq(select(2, config.resolve({ command = 5 })).field, "command")
end)

H.test("T-246 config.resolve: bin must be a string", function()
  eq(select(2, config.resolve({ bin = 5 })).field, "bin")
end)
