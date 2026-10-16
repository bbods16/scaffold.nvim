-- lua_test/buffer_spec.lua  -- PROVIDED. Do not edit; make the code pass. Test ids (T-nnn) are quoted in the spec.
local H = require("lua_test.harness")
local F = require("lua_test.fixtures")
local eq, raises = H.eq, H.raises
local config = require("scaffold.config")
local client = require("scaffold.client")
local buffer = require("scaffold.buffer")
local ui = require("scaffold.ui")
local commands = require("scaffold.commands")
local init = require("scaffold.init")

H.test("T-276 buffer.context: fields", function()
  local b = F.scratch("python", { "class A:", "    x = 1" }); vim.api.nvim_win_set_cursor(0, { 2, 0 }); local c = assert(buffer.context(b)); eq(c.filetype, "python"); eq(c.row, 2); eq(c.indent, "    "); eq(c.text, "class A:\n    x = 1")
end)

H.test("T-277 buffer.context: tabs count as indentation", function()
  local b = F.scratch("javascript", { "\t\tx" }); eq(assert(buffer.context(b)).indent, "\t\t")
end)

H.test("T-278 buffer.context: empty buffer", function()
  local b = F.scratch("ocaml", { "" }); local c = assert(buffer.context(b)); eq(c.row, 1); eq(c.indent, ""); eq(c.text, "")
end)

H.test("T-279 buffer.context: name of an unnamed buffer is empty", function()
  eq(assert(buffer.context(F.scratch("python", { "x" }))).name, "")
end)

H.test("T-280 buffer.context: invalid buffer", function()
  local c, e = buffer.context(99999); eq(c, nil); eq(e.code, "invalid_buffer"); eq(e.bufnr, 99999)
end)

H.test("T-281 buffer.insert_lines: inserts after the row", function()
  local b = F.scratch("python", { "a", "b" }); eq(buffer.insert_lines(b, 1, "x\ny"), true); eq(F.lines(b), { "a", "x", "y", "b" })
end)

H.test("T-282 buffer.insert_lines: row 0 is the top", function()
  local b = F.scratch("python", { "a" }); buffer.insert_lines(b, 0, "top"); eq(F.lines(b), { "top", "a" })
end)

H.test("T-283 buffer.insert_lines: row = last line appends", function()
  local b = F.scratch("python", { "a" }); buffer.insert_lines(b, 1, "end"); eq(F.lines(b), { "a", "end" })
end)

H.test("T-284 buffer.insert_lines: blank lines inside text are kept", function()
  local b = F.scratch("python", { "a" }); buffer.insert_lines(b, 1, "x\n\ny"); eq(F.lines(b), { "a", "x", "", "y" })
end)

H.test("T-285 buffer.insert_lines: row out of range", function()
  local b = F.scratch("python", { "a" }); local ok, e = buffer.insert_lines(b, 5, "x"); eq(ok, nil); eq(e.code, "api_error"); eq(F.lines(b), { "a" })
end)

H.test("T-286 buffer.insert_lines: invalid buffer", function()
  local ok, e = buffer.insert_lines(99999, 0, "x"); eq(ok, nil); eq(e.code, "invalid_buffer")
end)

H.test("T-287 buffer.write_file: writes lines", function()
  local d = F.tmpdir(); eq(buffer.write_file(d .. "/a.txt", "x\ny"), true); eq(vim.fn.readfile(d .. "/a.txt"), { "x", "y" }); F.rmrf(d)
end)

H.test("T-288 buffer.write_file: never overwrites", function()
  local d = F.tmpdir(); vim.fn.writefile({ "keep" }, d .. "/a.txt"); local ok, e = buffer.write_file(d .. "/a.txt", "new"); eq(ok, nil); eq(e, { code = "file_exists", path = d .. "/a.txt" }); eq(vim.fn.readfile(d .. "/a.txt"), { "keep" }); F.rmrf(d)
end)

H.test("T-289 buffer.write_file: missing directory", function()
  local ok, e = buffer.write_file("/nope/dir/a.txt", "x"); eq(ok, nil); eq(e.code, "api_error")
end)

H.test("T-290 buffer.open_file: returns the current buffer", function()
  local d = F.tmpdir(); vim.fn.writefile({ "x" }, d .. "/a.txt"); local b = assert(buffer.open_file(d .. "/a.txt")); eq(b, vim.api.nvim_get_current_buf()); eq(F.lines(b), { "x" }); F.rmrf(d)
end)

H.test("T-291 buffer.open_file: spaces in the path", function()
  local d = F.tmpdir(); vim.fn.writefile({ "y" }, d .. "/a b.txt"); local b = assert(buffer.open_file(d .. "/a b.txt")); eq(F.lines(b), { "y" }); F.rmrf(d)
end)

H.test("T-292 buffer.open_file: a refused :edit is reported, not raised", function()
  local hidden = vim.o.hidden; vim.o.hidden = false; vim.cmd.enew(); vim.bo.buftype = ""; vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved" }); local d = F.tmpdir(); vim.fn.writefile({ "x" }, d .. "/a.txt"); local b, e = buffer.open_file(d .. "/a.txt"); vim.bo.modified = false; vim.o.hidden = hidden; F.rmrf(d); eq(b, nil); eq(e.code, "api_error")
end)
