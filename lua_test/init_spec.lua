-- lua_test/init_spec.lua  -- PROVIDED. Do not edit; make the code pass. Test ids (T-nnn) are quoted in the spec.
local H = require("lua_test.harness")
local F = require("lua_test.fixtures")
local eq, raises = H.eq, H.raises
local config = require("scaffold.config")
local client = require("scaffold.client")
local buffer = require("scaffold.buffer")
local ui = require("scaffold.ui")
local commands = require("scaffold.commands")
local init = require("scaffold.init")

H.test("T-321 init.setup: registers command and keymap, returns the module", function()
  local m = init.setup({ command = "ScaffoldS1", keymap = "<leader>zs1" }); eq(m, init); assert(vim.api.nvim_get_commands({}).ScaffoldS1 ~= nil); assert(vim.fn.maparg("<leader>zs1", "n") ~= ""); init.teardown()
end)

H.test("T-322 init.setup: bin is handed to the client", function()
  init.setup({ command = "ScaffoldS2", keymap = "<leader>zs2", bin = "/opt/x" }); eq(client.bin, "/opt/x"); init.teardown(); eq(client.bin, nil)
end)

H.test("T-323 init.setup: second setup replaces the first", function()
  init.setup({ command = "ScaffoldS3", keymap = "<leader>zs3" }); init.setup({ command = "ScaffoldS3", keymap = "<leader>zs3" }); local n = 0; for _, g in ipairs(vim.api.nvim_get_autocmds({ group = "scaffold" })) do n = n + 1 end; assert(vim.api.nvim_get_commands({}).ScaffoldS3 ~= nil); init.teardown()
end)

H.test("T-324 init.setup: bad config raises with the field name", function()
  raises(function() init.setup({ mode = "bottom" }) end, "scaffold.setup: mode"); raises(function() init.setup({ command = "lower" }) end, "scaffold.setup: command")
end)

H.test("T-325 init.setup: a failed setup changes nothing", function()
  local ok, e = pcall(init.setup, { mode = "bottom", command = "ScaffoldS4" }); eq(ok, false); assert(F.has(tostring(e), "scaffold.setup: mode")); eq(vim.api.nvim_get_commands({}).ScaffoldS4, nil)
end)

H.test("T-326 init.run: cursor mode inserts below the cursor line", function()
  local b = F.scratch("python", { "x = 1", "y = 2" }); init.setup({ command = "ScaffoldR1", keymap = "<leader>zr1" }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run("union-find", "cursor"); ui.input = real; init.teardown(); local l = F.lines(b); eq(l[1], "x = 1"); assert(F.has(l[2], "class UnionFind")); eq(l[#l], "y = 2")
end)

H.test("T-327 init.run: answers are used", function()
  local b = F.scratch("python", { "" }); init.setup({ command = "ScaffoldR2", keymap = "<leader>zr2" }); local real = ui.input; local seen = {}; ui.input = function(p, g, cb) seen[#seen + 1] = p; cb(#seen == 1 and "my stack" or "bool") end; init.run("stack", "cursor"); ui.input = real; init.teardown(); eq(#seen, 2); eq(seen[1], "Type name"); assert(F.has(table.concat(F.lines(b), "\n"), "class MyStack"))
end)

H.test("T-328 init.run: indentation of the cursor line is applied", function()
  local b = F.scratch("python", { "    pass" }); init.setup({ command = "ScaffoldR3", keymap = "<leader>zr3" }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run("union-find", "cursor"); ui.input = real; init.teardown(); eq(F.lines(b)[2]:sub(1, 4), "    ")
end)

H.test("T-329 init.run: existing names in the buffer are avoided", function()
  local b = F.scratch("python", { "def binary_search(): pass" }); init.setup({ command = "ScaffoldR4", keymap = "<leader>zr4" }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run("binary-search", "function"); ui.input = real; init.teardown(); assert(F.has(table.concat(F.lines(b), "\n"), "def binary_search_2("))
end)

H.test("T-330 init.run: file mode writes and opens the file", function()
  local d = F.tmpdir(); local old = vim.fn.getcwd(); vim.cmd.cd(d); local b = F.scratch("javascript", { "" }); init.setup({ command = "ScaffoldR5", keymap = "<leader>zr5" }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run("stack", "file"); ui.input = real; init.teardown(); assert(vim.uv.fs_stat(d .. "/stack.js") ~= nil); assert(F.has(vim.api.nvim_buf_get_name(0), "stack.js")); vim.cmd.cd(old); F.rmrf(d)
end)

H.test("T-331 init.run: cancelling inserts nothing and stays silent", function()
  local b = F.scratch("python", { "x" }); init.setup({ command = "ScaffoldR6", keymap = "<leader>zr6" }); local n, restore = F.capture_notify(); local real = ui.input; ui.input = function(_, _, cb) cb(nil) end; init.run("stack", "cursor"); ui.input = real; restore(); init.teardown(); eq(F.lines(b), { "x" }); eq(#n, 0)
end)

H.test("T-332 init.run: unknown algorithm is reported", function()
  F.scratch("python", { "x" }); init.setup({ command = "ScaffoldR7", keymap = "<leader>zr7" }); local n, restore = F.capture_notify(); init.run("zzz", "cursor"); restore(); init.teardown(); eq(#n, 1); eq(n[1].level, vim.log.levels.ERROR); assert(F.has(n[1].msg, "unknown algorithm"))
end)

H.test("T-333 init.run: unsupported filetype is reported", function()
  F.scratch("lua", { "x" }); init.setup({ command = "ScaffoldR8", keymap = "<leader>zr8" }); local n, restore = F.capture_notify(); init.run("stack", "cursor"); restore(); init.teardown(); eq(#n, 1); assert(F.has(n[1].msg, "unknown language"))
end)

H.test("T-334 init.pick: menu items and titles", function()
  F.scratch("python", { "" }); init.setup({ command = "ScaffoldP1", keymap = "<leader>zp1" }); local real = vim.ui.select; local titles, prompt; vim.ui.select = function(items, o, cb) prompt = o.prompt; titles = {}; for _, i in ipairs(items) do titles[#titles + 1] = o.format_item(i) end end; init.pick(); vim.ui.select = real; init.teardown(); eq(prompt, "Algorithm"); eq(titles, { "Binary search", "Insertion sort", "Stack", "Union-find" })
end)

H.test("T-335 init.pick: choosing runs the algorithm", function()
  local b = F.scratch("python", { "" }); init.setup({ command = "ScaffoldP3", keymap = "<leader>zp3" }); local rs, ri = vim.ui.select, ui.input; vim.ui.select = function(items, _, cb) cb(items[4]) end; ui.input = function(_, g, cb) cb(g) end; init.pick(); vim.ui.select, ui.input = rs, ri; init.teardown(); assert(F.has(table.concat(F.lines(b), "\n"), "class UnionFind"))
end)

H.test("T-336 init.pick: cancelling the menu does nothing", function()
  local b = F.scratch("python", { "x" }); init.setup({ command = "ScaffoldP4", keymap = "<leader>zp4" }); local rs = vim.ui.select; vim.ui.select = function(_, _, cb) cb(nil) end; init.pick(); vim.ui.select = rs; init.teardown(); eq(F.lines(b), { "x" })
end)

H.test("T-337 init.pick: unsupported filetype is notified and no menu opens", function()
  F.scratch("lua", { "" }); init.setup({ command = "ScaffoldP5", keymap = "<leader>zp5" }); local n, restore = F.capture_notify(); local rs = vim.ui.select; local opened = false; vim.ui.select = function() opened = true end; init.pick(); vim.ui.select = rs; restore(); init.teardown(); eq(opened, false); eq(#n, 1)
end)

H.test("T-338 init.teardown: removes command, keymap and bin", function()
  init.setup({ command = "ScaffoldT9", keymap = "<leader>zt9", bin = "/opt/x" }); init.teardown(); eq(vim.api.nvim_get_commands({}).ScaffoldT9, nil); eq(vim.fn.maparg("<leader>zt9", "n"), ""); eq(client.bin, nil)
end)

H.test("T-339 init.teardown: idempotent", function()
  init.setup({ command = "ScaffoldT8", keymap = "<leader>zt8" }); init.teardown(); eq(pcall(init.teardown), true)
end)

H.test("T-340 init.teardown: safe before setup", function()
  init.teardown(); eq(pcall(init.teardown), true)
end)
