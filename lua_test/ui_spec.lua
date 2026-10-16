-- lua_test/ui_spec.lua  -- PROVIDED. Do not edit; make the code pass. Test ids (T-nnn) are quoted in the spec.
local H = require("lua_test.harness")
local F = require("lua_test.fixtures")
local eq, raises = H.eq, H.raises
local config = require("scaffold.config")
local client = require("scaffold.client")
local buffer = require("scaffold.buffer")
local ui = require("scaffold.ui")
local commands = require("scaffold.commands")
local init = require("scaffold.init")

H.test("T-293 ui.ghost_set: extmark with the text", function()
  local b = F.scratch("python", { "x" }); local id = assert(ui.ghost_set(b, 1, "hint")); eq(type(id), "number"); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; local m = vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, { details = true }); eq(#m, 1); eq(m[1][4].virt_text[1][1], "hint"); eq(m[1][2], 0)
end)

H.test("T-294 ui.ghost_set: row is 1-based", function()
  local b = F.scratch("python", { "a", "b" }); ui.ghost_set(b, 2, "t"); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; eq(vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, {})[1][2], 1)
end)

H.test("T-295 ui.ghost_set: invalid buffer", function()
  local id, e = ui.ghost_set(99999, 1, "x"); eq(id, nil); eq(e.code, "invalid_buffer")
end)

H.test("T-296 ui.ghost_clear: removes only our marks", function()
  local b = F.scratch("python", { "x" }); ui.ghost_set(b, 1, "a"); local other = vim.api.nvim_create_namespace("other"); vim.api.nvim_buf_set_extmark(b, other, 0, 0, {}); ui.ghost_clear(b); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; eq(#vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, {}), 0); eq(#vim.api.nvim_buf_get_extmarks(b, other, 0, -1, {}), 1)
end)

H.test("T-297 ui.ghost_clear: invalid buffer does not raise", function()
  eq(pcall(ui.ghost_clear, 99999), true)
end)

H.test("T-298 ui.input: opens a floating window with the ghost", function()
  local h = ui.input("Name", "ghost", function() end); eq(vim.api.nvim_win_is_valid(h.win), true); eq(vim.api.nvim_win_get_config(h.win).relative, "editor"); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; eq(#vim.api.nvim_buf_get_extmarks(h.buf, ns, 0, -1, {}), 1); h.close(nil)
end)

H.test("T-299 ui.input: close(value) calls back with the value after closing", function()
  local got, win_open_at_callback; local h; h = ui.input("P", "g", function(v) got = v; win_open_at_callback = vim.api.nvim_win_is_valid(h.win) end); h.close("abc"); vim.wait(500, function() return got ~= nil end); eq(got, "abc"); eq(win_open_at_callback, false)
end)

H.test("T-300 ui.input: cancel passes nil", function()
  local called, got = false, "unset"; local h = ui.input("P", "g", function(v) called = true; got = v end); h.close(nil); vim.wait(500, function() return called end); eq(called, true); eq(got, nil)
end)

H.test("T-301 ui.input: callback fires exactly once", function()
  local n = 0; local h = ui.input("P", "g", function() n = n + 1 end); h.close("a"); h.close("b"); h.close(nil); vim.wait(100); eq(n, 1)
end)

H.test("T-302 ui.input: <CR> in insert mode submits the first line", function()
  local got; local h = ui.input("P", "g", function(v) got = v end); vim.api.nvim_buf_set_lines(h.buf, 0, -1, false, { "typed" }); vim.api.nvim_set_current_win(h.win); local keymap = vim.fn.maparg("<CR>", "i", false, true); keymap.callback(); vim.wait(500, function() return got ~= nil end); eq(got, "typed")
end)

H.test("T-303 ui.input: <Esc> cancels", function()
  local called, got = false, "unset"; local h = ui.input("P", "g", function(v) called = true; got = v end); vim.api.nvim_set_current_win(h.win); local keymap = vim.fn.maparg("<Esc>", "n", false, true); keymap.callback(); vim.wait(500, function() return called end); eq(got, nil); eq(called, true)
end)

H.test("T-304 ui.input: on_done must be a function", function()
  raises(function() ui.input("P", "g", nil) end, "on_done must be a function"); raises(function() ui.input("P", "g", "x") end, "on_done")
end)
