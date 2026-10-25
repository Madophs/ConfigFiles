vim.g.nightflyUnderlineMatchParen = true
vim.g.nightflyCursorColor = true
vim.g.nightflyTransparent = true

require("config.lazy")
require("postconfig.cmp_config")
vim.api.nvim_exec2("source ${MDS_VIM}/vimrc", { output = true })

-- Disable ALE's internal LSP behavior completely
vim.g.ale_disable_lsp = 1

-- Prevent ALE from providing completion suggestions
vim.g.ale_completion_enabled = 0

-- Prevent ALE from providing Go To Definition capabilities
vim.g.ale_definition_iterator_enabled = 0

-- Keep ALE linters fast by utilizing Neovim's native diagnostics handler
vim.g.ale_use_neovim_diagnostics_api = 1

vim.opt.lazyredraw = true

if vim.g.neovide then
  vim.fn.setenv("MDS_FANCY", "YES")
  vim.fn.setenv("MDS_SESSIONS_DIR", "$HOME/.config/mdsconfig/sessions")
  vim.g.neovide_opacity = 0.75
  vim.g.neovide_normal_opacity = 0.75
  vim.g.neovide_multigrid = true
  vim.g.neovide_fullscreen = true
end

vim.opt.signcolumn="auto:3"

vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')
vim.lsp.enable('bashls')
