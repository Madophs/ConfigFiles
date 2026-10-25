return {
  {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme nightfly ]])
    end,
  },
  { 'rebelot/kanagawa.nvim', lazy = false, priority = 1000 },
  { 'oxfist/night-owl.nvim', lazy = false, priority = 1000 },
  { 'dracula/vim', as = 'dracula', lazy = false, priority = 1000 },
  { 'bluz71/vim-moonfly-colors', lazy = false, priority = 1000 },
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      folds = { enable = true },
    },
    config = function()
      -- The new method to download your parsers asynchronously
      require("nvim-treesitter").install({
        "c", "cpp", "rust", "make", "blade", "bash"
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          local has_parser = vim.treesitter.query.get(lang, "highlights") ~= nil
          if lang and has_parser and pcall(vim.treesitter.get_parser, buf, lang) then
            vim.treesitter.start(buf, lang)
          end
        end,
      })
    end,
  },
  {
    'KaitoMuraoka/websearcher.nvim',
    keys = {
      { "<leader>ss", mode = { "x" }, function() require("websearcher").search_selected() end, desc = "Web search" },
    },
    opts = {},
  },
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true
        },
        indent = {
          enable = true,
          chars = {
            "│",
          },
          style = {
            "#FF0000",
            "#FF7F00",
            "#FFFF00",
            "#00FF00",
            "#00FFFF",
            "#0000FF",
            "#8B00FF",
          },
        },
        line_num = {
          enable = true
        },
        blank = {
          enable = false,
        }
      })
    end
  },
  { 'dense-analysis/ale', opts = {} },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {}
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
    opts = {},
  },
  {
    'Wansmer/treesj',
    keys = { '<space>m', '<space>j', '<space>s' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- Enable repeatable jumps if you want them (optional)
      require("nvim-treesitter-textobjects").setup({
        move = {
          enable = true,
          set_jumps = true,
        }
      })

      -- Define your textobject jump keymaps using native Neovim APIs
      local move = require("nvim-treesitter-textobjects.move")

      -- Next function/class/parameter start
      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "]s", function() move.goto_next_start("@class.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "]a", function() move.goto_next_start("@parameter.inner") end)
      vim.keymap.set({ "n", "x", "o" }, "]o", function() move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects") end)

      -- Next function/class/parameter end
      vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "]S", function() move.goto_next_end("@class.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "]A", function() move.goto_next_end("@parameter.inner") end)
      vim.keymap.set({ "n", "x", "o" }, "]O", function() move.goto_next_end({ "@loop.inner", "@loop.outer" }, "textobjects") end)

      -- Previous function/class/parameter start
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "[s", function() move.goto_previous_start("@class.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "[a", function() move.goto_previous_start("@parameter.inner") end)
      vim.keymap.set({ "n", "x", "o" }, "[o", function() move.goto_previous_start({ "@loop.outer", "@loop.inner" }, "textobjects") end)

      -- Previous function/class/parameter end
      vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "[S", function() move.goto_previous_end("@class.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "[A", function() move.goto_previous_end("@parameter.inner") end)

    end,
  },
  {
    'aaronik/treewalker.nvim',
    opts = {},
    config = function ()
      vim.keymap.set({ 'n', 'v' }, '<D-k>', '<cmd>Treewalker Up<cr>', { silent = true })
      vim.keymap.set({ 'n', 'v' }, '<D-j>', '<cmd>Treewalker Down<cr>', { silent = true })
      vim.keymap.set({ 'n', 'v' }, '<D-h>', '<cmd>Treewalker Left<cr>', { silent = true })
      vim.keymap.set({ 'n', 'v' }, '<D-l>', '<cmd>Treewalker Right<cr>', { silent = true })
      vim.keymap.set('n', '<space>k', '<cmd>Treewalker SwapUp<cr>', { silent = true })
      vim.keymap.set('n', '<space>j', '<cmd>Treewalker SwapDown<cr>', { silent = true })
      vim.keymap.set('n', '<space>h', '<cmd>Treewalker SwapLeft<cr>', { silent = true })
      vim.keymap.set('n', '<space>l', '<cmd>Treewalker SwapRight<cr>', { silent = true })
    end
  },
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = { },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { enabled = false },
      },
    },
    keys = {
      { "f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "F", mode = { "n", "x", "o" }, function() require("flash").treesitter_search() end, desc = "Flash Treesitter" },
    },
  },
  {
    "dstein64/nvim-scrollview",
    opts = {
      excluded_filetypes = {'nerdtree'},
      current_only = true,
      signs_on_startup = {'indent', 'cursor', 'marks', 'search', 'keywords', 'diagnostics', 'conflicts'},
    }
  },
  { "chentoast/marks.nvim", event = "VeryLazy", opts = {} },
  { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
  { "kylechui/nvim-surround", version = "^4.0.0", event = "VeryLazy", },
  { 'lewis6991/gitsigns.nvim' },
  { 'andersevenrud/nvim_context_vt' },
  { 'm-demare/hlargs.nvim',  opts = {} },
  { 'HiPhish/rainbow-delimiters.nvim' },
  { 'nvim-treesitter/nvim-treesitter-context' },
  --{ 'neoclide/coc.nvim', branch = 'release', },
  { 'scrooloose/nerdtree' },
  { 'vifm/vifm.vim' },
  { 'preservim/nerdcommenter' },
  { 'airblade/vim-gitgutter' },
  { 'mattn/emmet-vim' },
  { 'tpope/vim-fugitive' },
  { 'ryanoasis/vim-devicons' },
  { 'preservim/tagbar' },
  --{'junegunn/fzf', { 'do': { -> fzf#install() } }},
  --{'junegunn/fzf.vim'},
  { 'inside/vim-search-pulse' },
  { 'mhinz/vim-startify' },
  { 'cdelledonne/vim-cmake' },
  { 'bronson/vim-visual-star-search' },
  { 'voldikss/vim-floaterm' },
  { 'tpope/vim-rhubarb' },
  { 'ludovicchabant/vim-gutentags' },
  { 'Shirk/vim-gas' },
  { "mason-org/mason.nvim", opts = {} },
  { 'neovim/nvim-lspconfig' },

}

