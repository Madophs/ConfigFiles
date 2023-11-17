-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require('nvim-treesitter.configs').setup {
    ensure_installed = {
        "c", "cpp", "lua", "vim", "vimdoc", "query", "java", "rust", "php", "javascript", "json", "python", "yaml", "html", "cuda", "bash"
    },
    highlight = {
        enable = true,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    refactor = {
        highlight_definitions = {
            enable = true,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = true,
        },
    },
}

-- This module contains a number of default definitions
local rainbow_delimiters = require 'rainbow-delimiters'

vim.g.rainbow_delimiters = {
    strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
    },
    query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
    },
    highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
    },
}


local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}

local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

require("ibl").setup { indent = { highlight = highlight } }

require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
-- place this in one of your configuration file(s)
local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, {remap=true})
vim.keymap.set('', 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, {remap=true})
vim.keymap.set('', 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, {remap=true})
vim.keymap.set('', 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, {remap=true})
--require('tsht').move({ side = "start" })

require('lualine').setup()
-- dont run neodev.setup
--vim.lsp.start({
  --name = "lua-language-server",
  --cmd = { "lua-language-server" },
  --before_init = require("neodev.lsp").before_init,
  --root_dir = vim.fn.getcwd(),
  --settings = { Lua = {} },
--})
--local lsp_zero = require('lsp-zero')

--lsp_zero.on_attach(function(client, bufnr)
  ---- see :help lsp-zero-keybindings
  ---- to learn the available actions
  --lsp_zero.default_keymaps({buffer = bufnr})
--end)

---
-- Replace these language servers
-- with the ones you have installed in your system
---
--require('lspconfig').lua_ls.setup({})
--require('neodev').setup({})
--require('lspconfig').rust_analyzer.setup({})
--require('lspconfig').lua_ls.setup({
  --settings = {
    --Lua = {
      --completion = {
        --callSnippet = "Replace"
      --}
    --}
  --}
--})

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use "lukas-reineke/indent-blankline.nvim"

  use 'voldikss/vim-floaterm'

  -- Simple plugins can be specified as strings
  --use '9mm/vim-closer'

  -- Lazy loading:
  -- Load on specific commands
  use {'tpope/vim-dispatch', opt = true, cmd = {'Dispatch', 'Make', 'Focus', 'Start'}}

  -- Load on an autocommand event
  use {'andymass/vim-matchup', event = 'VimEnter'}

  -- Load on a combination of conditions: specific filetypes or commands
  -- Also run code after load (see the "config" key)
  use {
    'w0rp/ale',
    ft = {'sh', 'zsh', 'bash', 'c', 'cpp', 'cmake', 'html', 'markdown', 'racket', 'vim', 'tex'},
    cmd = 'ALEEnable',
    config = 'vim.cmd[[ALEEnable]]'
  }

  -- Plugins can have dependencies on other plugins
  use {
    'haorenW1025/completion-nvim',
    opt = true,
    requires = {{'hrsh7th/vim-vsnip', opt = true}, {'hrsh7th/vim-vsnip-integ', opt = true}}
  }

  -- Plugins can also depend on rocks from luarocks.org:
  --use {
    --'my/supercoolplugin',
    --rocks = {'lpeg', {'lua-cjson', version = '2.1.0'}}
  --}

  -- You can specify rocks in isolation
  use_rocks 'penlight'
  use_rocks {'lua-resty-http', 'lpeg'}

  -- Local plugins can be included
  --use '~/projects/personal/hover.nvim'

  -- Plugins can have post-install/update hooks
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}

  -- Post-install/update hook with neovim command
  --use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }

  use {'HiPhish/rainbow-delimiters.nvim'}

  use {'nvim-treesitter/nvim-treesitter-refactor'}

  use {'nvim-treesitter/nvim-treesitter-context'}

  use {'mfussenegger/nvim-treehopper'}

  use { 'smoka7/hop.nvim', tag = 'v2.5.0' }

  -- Post-install/update hook with call of vimscript function with argument
  use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

  -- Use specific branch, dependency and run lua file after load
  use {
    'glepnir/galaxyline.nvim', branch = 'main', config = function() require'statusline' end,
    requires = {'kyazdani42/nvim-web-devicons'}
  }

  -- Use dependency and run lua function after load
  use {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  }

  -- You can specify multiple plugins in a single call
  --use {'tjdevries/colorbuddy.vim', {'nvim-treesitter/nvim-treesitter', opt = true}}

  -- You can alias plugin names
  use {'dracula/vim', as = 'dracula'}

  use { 'bluz71/vim-moonfly-colors', as = 'moonfly' }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  --use {'hrsh7th/nvim-cmp'}

  --use {'folke/neodev.nvim', opts={}}

  --use {'neovim/nvim-lspconfig'}
--use {
  --'VonHeikemen/lsp-zero.nvim',
  --branch = 'v3.x',
  --requires = {
    --- Uncomment these if you want to manage LSP servers from neovim
     --{'williamboman/mason.nvim'},
     --{'williamboman/mason-lspconfig.nvim'},

     --LSP Support
    --{'neovim/nvim-lspconfig'},
     --Autocompletion
    --{'hrsh7th/nvim-cmp'},
    --{'hrsh7th/cmp-nvim-lsp'},
    --{'L3MON4D3/LuaSnip'},
  --}
--}

  -- These optional plugins should be loaded directly because of a bug in Packer lazy loading
  --use 'nvim-tree/nvim-web-devicons' -- OPTIONAL: for file icons
  use 'romgrk/barbar.nvim'

  if packer_bootstrap then
    require('packer').sync()
  end
end)
