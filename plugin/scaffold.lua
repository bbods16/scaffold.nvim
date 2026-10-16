-- plugin/scaffold.lua  -- PROVIDED (boilerplate). Neovim sources plugin/*.lua at startup.
-- Keep it tiny: a guard variable and a version check. No require of heavy modules here.
if vim.g.loaded_scaffold then return end
vim.g.loaded_scaffold = true
if vim.fn.has('nvim-0.10') == 0 then
  vim.notify('scaffold.nvim needs Neovim 0.10 or newer', vim.log.levels.WARN)
end
