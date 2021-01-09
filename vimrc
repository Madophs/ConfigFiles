set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
call plug#begin('~/.vim/plugged')

Plug 'VundleVim/Vundle.vim'
Plug 'Valloric/YouCompleteMe'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'scrooloose/nerdtree'
Plug 'vifm/vifm.vim'
Plug 'preservim/nerdcommenter'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-fugitive'
Plug 'turbio/bracey.vim'
Plug 'StanAngeloff/php.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'preservim/tagbar'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-signify'
Plug 'yggdroot/indentline'
Plug 'crusoexia/vim-monokai'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-vinegar'
Plug 'embark-theme/vim'
Plug 'ghifarit53/tokyonight-vim'
Plug 'bluz71/vim-nightfly-guicolors'
Plug 'luochen1990/rainbow'
Plug 'terryma/vim-smooth-scroll'
Plug 'inside/vim-search-pulse'
Plug 'mhinz/vim-startify'
Plug 'pboettch/vim-cmake-syntax'
Plug 'vhdirk/vim-cmake'

call plug#end()
filetype plugin indent on

" Configuration for html files
autocmd FileType html setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab

" Set the working directory to the current's file directory
" Issues with terminal buffer
"autocmd BufEnter * lcd %:p:h

" Highlight trailing spaces automatically
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
"autocmd InsertEnter FiletyIndentLinesEnable
autocmd InsertEnter,CursorMoved *.cpp IndentLinesReset

" Global configurations
syntax on

" Search related configs
set path=.,$MDS_ROOT,$MDS_ROOT/**,
set hlsearch
set incsearch
set ignorecase
set smartcase

" Space / indenting related configs
set tabstop=4
set softtabstop=4 expandtab
set shiftwidth=4
set autoindent
set smartindent
set shiftround
set autoindent

" Editor related configs
set cursorline
set number
set relativenumber
set mouse=ni
set showmatch
set wrap
set linebreak
set showbreak=↳
set breakindent
set scrolloff=2
set ruler
set foldmethod=indent
set nofoldenable

" Behavior
set autochdir
set updatetime=3000
set autoread | au CursorHold,FocusGained,BufEnter * checktime
set autowrite
set noshowmode
set splitbelow
set splitright
set confirm

" Terminal related configs
set term=screen-256color
set encoding=UTF-8
set t_ut=
set visualbell

" Here start miscellaneous configs
set wildmenu
set wildmode=list:longest,full
set title
set backspace=indent,eol,start
set noswapfile

" Bind VIM clipboard registry with Linux's
set clipboard=unnamedplus

" Add Cool status line
set laststatus=2

" Set tags location
set tags=$TAGS

" I use Konsole terminal so let's add some color
" For more info :h xterm-true-color
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" Nice looking terminal
set termguicolors

" Beautiful theme
colorscheme nightfly
let g:lightline = { 'colorscheme': 'nightfly' }
let g:nightflyUnderlineMatchParen = 1
let g:nightflyCursorColor = 1

" Source files (Usually functions)
source $MDS_CONFIG/ToggleIOBuffers.vim
source $MDS_CONFIG/Kwbd.vim

" Mappings
map <F2> :YcmCompleter GoTo <CR>
map <F3> :YcmCompleter GoToReferences <CR>
map <F7> :w<CR>:! clear && mdscode -b % && mdscode -rio
map <F8> :w<CR>:! clear && mdscode -rio
map <F9> :call ToggleIOBuffers($MDS_INPUT,$MDS_OUTPUT) <CR>
map <F10> :setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab smartindent <CR>

map <c-h> :grep -rn $MDS_ROOT --exclude-dir=storage --exclude-dir=vendor --exclude-dir=node_modules --exclude=tags --exclude="*.json" -e
map <F6> :vertical split /home/madophs/MdsCode/input.txt<CR>:split /home/madophs/MdsCode/output.txt <CR>
"map <C-i> :cd $MDS_ROOT <CR>
map <C-n> :NERDTreeToggle<CR>
nnoremap <leader>n :NERDTreeFocus<CR>
map <F4> :TagbarToggle<CR>
nnoremap <M-Right> <C-w>l
nnoremap <M-Left> <C-w>h
nnoremap <M-Down> <C-w>j
nnoremap <M-Up> <C-w>k
map <C-k> :Kwbd <CR>
map <C-L> :Buffers <CR>

" Smooth scrolling
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

" Indentation character list
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_enabled = 1

" Parenthesis colors
let g:rainbow_active = 1

" Disable Rainbow plugin when editing cmake files
autocmd FileType cmake RainbowToggleOff

let g:vim_search_pulse_duration = 200

" NERDTree configurations
"let NERDTreeShowHidden=1

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" YouCompleteme configuration
"let g:ycm_global_ycm_extra_conf = '$HOME/.vim/plugged/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_completion=1
"let g:ycm_show_diagnostics_ui = 0
let g:ycm_use_clang=1

" For more info check:
" https://releases.llvm.org/10.0.0/tools/clang/tools/extra/docs/clangd/Installation.html
" Let clangd fully control code completion
let g:ycm_clangd_uses_ycmd_caching = 0
" Use installed clangd, not YCM-bundled clangd which doesn't get updates.
let g:ycm_clangd_binary_path = exepath("clangd")

let g:trim_trailing_whitespace="true"

" netrw configurations
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
let g:netrw_winsize = 25
let g:netrw_keepdir=0 " Netrw: keeps track of current browsing directory

" CMake configurations
let g:cmake_export_compile_commands = 1
let g:cmake_ycm_symlinks = 1

" fzf stuff
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}, <bang>0)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

augroup MdsYCM
  autocmd!
  autocmd FileType c,cpp,python let b:ycm_hover = {
    \ 'command': 'GetDoc',
    \ 'syntax': &filetype
    \ }
augroup END

" Tagbar kinds configuration

let g:tagbar_type_cpp = {
    \ 'kinds' : [
        \ 'd:macros:1:0',
        \ 'p:prototypes:0:0',
        \ 'g:enums',
        \ 'e:enumerators:0:0',
        \ 't:typedefs:0:0',
        \ 'n:namespaces',
        \ 'c:classes',
        \ 's:structs',
        \ 'u:unions',
        \ 'f:functions',
        \ 'm:members:0:0',
        \ 'v:variables:0:0',
        \ '?:unknown',
    \ ],
\ }


let g:tagbar_type_php = {
    \ 'kinds' : [
        \ 'i:interfaces',
        \ 'c:classes',
        \ 'd:constant definitions:0:0',
        \ 'f:functions',
        \ 'j:javascript functions',
    \ ],
\ }

