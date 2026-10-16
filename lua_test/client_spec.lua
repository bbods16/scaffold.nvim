-- lua_test/client_spec.lua  -- PROVIDED. Do not edit; make the code pass. Test ids (T-nnn) are quoted in the spec.
local H = require("lua_test.harness")
local F = require("lua_test.fixtures")
local eq, raises = H.eq, H.raises
local config = require("scaffold.config")
local client = require("scaffold.client")
local buffer = require("scaffold.buffer")
local ui = require("scaffold.ui")
local commands = require("scaffold.commands")
local init = require("scaffold.init")

H.test("T-247 client.binary: client.bin wins over the environment", function()
  F.with_clean_engine(function() vim.env.SCAFFOLD_BIN = "/bin/false"; client.bin = "/bin/sh"; eq(client.binary(), "/bin/sh") end)
end)

H.test("T-248 client.binary: environment variable is used next", function()
  F.with_clean_engine(function() vim.env.SCAFFOLD_BIN = "/bin/sh"; eq(client.binary(), "/bin/sh") end)
end)

H.test("T-249 client.binary: default path ends with the dune output", function()
  F.with_clean_engine(function() local p = client.binary(); eq(type(p), "string"); eq(p:sub(-#"/_build/default/bin/main.exe"), "/_build/default/bin/main.exe") end)
end)

H.test("T-250 client.binary: missing binary", function()
  F.with_clean_engine(function() client.bin = "/nope/engine"; local p, e = client.binary(); eq(p, nil); eq(e.code, "engine_missing"); eq(e.path, "/nope/engine"); assert(F.has(e.message, "dune build")) end)
end)

H.test("T-251 client.binary: not executable counts as missing", function()
  F.with_clean_engine(function() local d = F.tmpdir(); vim.fn.writefile({ "x" }, d .. "/plain"); client.bin = d .. "/plain"; eq(select(2, client.binary()).code, "engine_missing"); F.rmrf(d) end)
end)

H.test("T-252 client.call: list reply decodes", function()
  local d = assert(client.call({ "list", "--lang", "ocaml" })); eq(#d.items, 4); eq(d.items[1].id, "binary-search")
end)

H.test("T-253 client.call: stdin is forwarded", function()
  local d = assert(client.call({ "gen", "--lang", "python", "--algo", "binary-search", "--scan", "-" }, "def binary_search(): pass")); assert(F.has(d.text, "binary_search_2"))
end)

H.test("T-254 client.call: args are not mutated", function()
  local a = { "list", "--lang", "python" }; client.call(a); eq(a, { "list", "--lang", "python" })
end)

H.test("T-255 client.call: domain error", function()
  local d, e = client.call({ "list", "--lang", "cobol" }); eq(d, nil); eq(e.code, "unknown_lang"); eq(e.message, "unknown language: cobol")
end)

H.test("T-256 client.call: usage error", function()
  local d, e = client.call({ "gen", "--bogus" }); eq(d, nil); eq(e.code, "unknown_flag")
end)

H.test("T-257 client.call: missing engine", function()
  F.with_clean_engine(function() client.bin = "/nope/engine"; local d, e = client.call({ "list" }); eq(d, nil); eq(e.code, "engine_missing") end)
end)

H.test("T-258 client.call: engine prints garbage", function()
  F.with_clean_engine(function() local dir = F.tmpdir(); client.bin = F.fake_bin(dir, "echo not json"); local d, e = client.call({ "list" }); eq(d, nil); eq(e.code, "bad_json"); F.rmrf(dir) end)
end)

H.test("T-259 client.call: engine prints valid JSON that is not an object", function()
  F.with_clean_engine(function() local dir = F.tmpdir(); client.bin = F.fake_bin(dir, "echo 42"); eq(select(2, client.call({ "list" })).code, "bad_json"); F.rmrf(dir) end)
end)

H.test("T-260 client.call: --json is appended last", function()
  F.with_clean_engine(function() local dir = F.tmpdir(); client.bin = F.fake_bin(dir, 'echo "{\\"argv\\":\\"$*\\"}"'); local d = assert(client.call({ "list", "--lang", "x" })); eq(d.argv, "list --lang x --json"); F.rmrf(dir) end)
end)

H.test("T-261 client.list: four items", function()
  local items = assert(client.list("python")); eq(#items, 4); eq(items[2], { id = "insertion-sort", title = "Insertion sort", group = "sorting" })
end)

H.test("T-262 client.list: filetype alias", function()
  eq(#assert(client.list("javascriptreact")), 4)
end)

H.test("T-263 client.list: unknown filetype", function()
  local items, e = client.list("lua"); eq(items, nil); eq(e.code, "unknown_lang")
end)

H.test("T-264 client.prompts: prompts for stack", function()
  local ps = assert(client.prompts("python", "stack")); eq(#ps, 2); eq(ps[1], { name = "type_name", prompt = "Type name", ghost = "Stack" })
end)

H.test("T-265 client.prompts: ghost follows the language style", function()
  eq(assert(client.prompts("javascript", "binary-search"))[1].ghost, "binarySearch")
end)

H.test("T-266 client.prompts: unknown algorithm", function()
  local ps, e = client.prompts("python", "zzz"); eq(ps, nil); eq(e.code, "unknown_algo")
end)

H.test("T-267 client.prompts: unknown filetype", function()
  eq(select(2, client.prompts("lua", "stack")).code, "unknown_lang")
end)

H.test("T-268 client.generate: cursor mode has no file", function()
  local r = assert(client.generate({ filetype = "python", algo = "union-find" })); eq(r.file, nil); assert(F.has(r.text, "class UnionFind"))
end)

H.test("T-269 client.generate: answers are applied", function()
  local r = assert(client.generate({ filetype = "python", algo = "stack", answers = { { name = "type_name", value = "my stack" }, { name = "elem", value = "bool" } } })); assert(F.has(r.text, "class MyStack"))
end)

H.test("T-270 client.generate: file mode returns a name", function()
  local r = assert(client.generate({ filetype = "javascript", algo = "stack", mode = "file", answers = { { name = "type_name", value = "int stack" } } })); eq(r.file, "intStack.js"); eq(type(r.text), "string")
end)

H.test("T-271 client.generate: indent is applied in cursor mode", function()
  local r = assert(client.generate({ filetype = "python", algo = "union-find", indent = 4 })); eq(r.text:sub(1, 4), "    ")
end)

H.test("T-272 client.generate: buffer text avoids clashes", function()
  local r = assert(client.generate({ filetype = "python", algo = "binary-search", text = "def binary_search(): pass" })); assert(F.has(r.text, "def binary_search_2("))
end)

H.test("T-273 client.generate: bad answer", function()
  local r, e = client.generate({ filetype = "python", algo = "stack", answers = { { name = "elem", value = "double" } } }); eq(r, nil); eq(e.code, "bad_elem")
end)

H.test("T-274 client.generate: bad mode is a usage error", function()
  eq(select(2, client.generate({ filetype = "python", algo = "stack", mode = "zzz" })).code, "bad_value")
end)

H.test("T-275 client.generate: unknown algorithm", function()
  eq(select(2, client.generate({ filetype = "python", algo = "zzz" })).code, "unknown_algo")
end)
