-- lua_test/fixtures.lua  -- PROVIDED. Small helpers shared by the Lua specs.
local F = {}

-- A fresh scratch buffer made current, with a filetype and some lines.
function F.scratch(ft, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = ft or ""
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines or { "" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  return buf
end

-- Replace vim.notify; returns (list, restore). Each entry is { msg, level }.
function F.capture_notify()
  local saved, got = vim.notify, {}
  vim.notify = function(msg, level) got[#got + 1] = { msg = msg, level = level } end
  return got, function() vim.notify = saved end
end

-- A new empty temp directory (removed with F.rmrf).
function F.tmpdir()
  local d = vim.fn.tempname()
  vim.fn.mkdir(d, "p")
  return d
end
function F.rmrf(path) vim.fn.delete(path, "rf") end

-- An executable shell script (POSIX only). Returns its path.
function F.fake_bin(dir, body)
  local p = dir .. "/fake-engine"
  vim.fn.writefile({ "#!/bin/sh", body }, p)
  vim.uv.fs_chmod(p, tonumber("755", 8))
  return p
end

-- Run fn(); always restore client.bin / SCAFFOLD_BIN afterwards.
function F.with_clean_engine(fn)
  local client = require("scaffold.client")
  local old_bin, old_env = client.bin, vim.env.SCAFFOLD_BIN
  client.bin, vim.env.SCAFFOLD_BIN = nil, nil
  local ok, err = pcall(fn)
  client.bin, vim.env.SCAFFOLD_BIN = old_bin, old_env
  if not ok then error(err, 0) end
end

function F.lines(buf) return vim.api.nvim_buf_get_lines(buf, 0, -1, false) end
function F.has(s, sub) return s:find(sub, 1, true) ~= nil end
return F
