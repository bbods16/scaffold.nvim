local H = {}
local cases = {}
function H.reset() cases = {} end
function H.names() local out = {} for _, c in ipairs(cases) do out[#out + 1] = c.name end return out end
function H.test(name, body)
  if type(name) ~= "string" or name == "" then error("harness.test: name must be a non-empty string", 2) end
  if type(body) ~= "function" then error("harness.test: body must be a function", 2) end
  cases[#cases + 1] = { name = name, body = body }
end
function H.eq(actual, expected, msg)
  if vim.deep_equal(actual, expected) then return true end
  error(("%sexpected %s, got %s"):format(msg and (msg .. ": ") or "", vim.inspect(expected), vim.inspect(actual)), 2)
end
function H.raises(f, pattern)
  local ok, err = pcall(f)
  if ok then error("expected an error but f did not raise", 2) end
  if not tostring(err):find(pattern, 1, true) then error(("error message did not contain %q: %s"):format(pattern, tostring(err)), 2) end
  return true
end
function H.run()
  local passed, failed = 0, 0
  for _, c in ipairs(cases) do
    local ok, err = pcall(c.body)
    if ok then passed = passed + 1; print("PASS " .. c.name)
    else failed = failed + 1; print("FAIL " .. c.name .. "\n     " .. tostring(err)) end
  end
  print(("%d passed, %d failed"):format(passed, failed))
  return failed
end
return H
