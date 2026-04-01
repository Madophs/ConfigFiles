require('nvim-treesitter').install {
    'c', 'cpp', 'lua', 'vim', 'vimdoc', 'query', 'java', 'rust', 'php', 'javascript', 'json',
    'python', 'yaml', 'html', 'cuda', 'bash', 'css', 'gitignore', 'go', 'graphql', 'haskell',
    'llvm', 'lua', 'make', 'objdump', 'r', 'typescript', 'nasm'
}

---- rainbow-delimiters configs
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

-- place this in one of your configuration file(s)
local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', 'f', function()
  hop.hint_char1({ current_line_only = false})
end, {remap=true})
vim.keymap.set('', 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, {remap=true})
vim.keymap.set('', 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, {remap=true})
--require('tsht').move({ side = "start" })

require("ibl").setup { indent = { highlight = highlight } }

require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }

require('lualine').setup()

require('nvim-surround').setup()

require('hlargs').setup()

require('neoscroll').setup({
  mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
    '<C-u>', '<C-d>',
    '<C-b>', '<C-f>',
    '<C-y>', '<C-e>',
    'zt', 'zz', 'zb',
  },
  hide_cursor = true,          -- Hide cursor while scrolling
  stop_eof = true,             -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  duration_multiplier = 1.0,   -- Global duration multiplier
  easing = 'linear',           -- Default easing function
  pre_hook = nil,              -- Function to run before the scrolling animation starts
  post_hook = nil,             -- Function to run after the scrolling animation ends
  performance_mode = false,    -- Disable "Performance Mode" on all buffers.
  ignored_events = {           -- Events ignored while scrolling
      'WinScrolled', 'CursorMoved'
  },
})

vim.api.nvim_set_keymap("v", "<leader>ss", ":lua require('websearcher').search_selected()<CR>", { noremap = true, silent = true })

vim.opt.lazyredraw = true

if vim.g.neovide then
    vim.fn.setenv("MDS_FANCY", "YES")
    vim.fn.setenv("MDS_SESSIONS_DIR", "$HOME/.config/mdsconfig/sessions")
    vim.g.neovide_opacity = 0.75
    vim.g.neovide_normal_opacity = 0.75
    vim.g.neovide_multigrid = true
    vim.g.neovide_fullscreen = true
end
