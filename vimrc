set nocompatible              " be iMproved, required
filetype off                  " required

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" set the runtime path to include Vundle and initialize
call plug#begin('~/.vim/plugged')

Plug 'VundleVim/Vundle.vim'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'scrooloose/nerdtree'
Plug 'vifm/vifm.vim'
Plug 'preservim/nerdcommenter'
"Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-fugitive'
Plug 'turbio/bracey.vim'
Plug 'StanAngeloff/php.vim'
if $MDS_FANCY ==? "yes"
    Plug 'ryanoasis/vim-devicons'
    Plug 'bluz71/vim-nightfly-guicolors'
    Plug 'ghifarit53/tokyonight-vim'
endif
Plug 'preservim/tagbar'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
"Plug 'mhinz/vim-signify'
Plug 'yggdroot/indentline'
Plug 'crusoexia/vim-monokai'
Plug 'tpope/vim-vinegar'
Plug 'embark-theme/vim'
Plug 'luochen1990/rainbow'
Plug 'terryma/vim-smooth-scroll'
Plug 'inside/vim-search-pulse'
Plug 'mhinz/vim-startify'
Plug 'pboettch/vim-cmake-syntax'
Plug 'vim-python/python-syntax'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'uiiaoo/java-syntax.vim'
Plug 'cdelledonne/vim-cmake'
"Plug 'ycm-core/YouCompleteMe'
Plug 'bronson/vim-visual-star-search'
Plug 'voldikss/vim-floaterm'
Plug 'rust-lang/rust.vim'
if ! has('nvim')
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
endif

call plug#end()
filetype plugin indent on

" autocmd section

" Configuration for html files
autocmd FileType html,typescript,javascript,blade setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd BufEnter,BufNewFile,BufRead *.s,*.asm,*.S set filetype=nasm

" Set the working directory to the current's file directory
" Issues with terminal buffer
"autocmd BufEnter * lcd %:p:h

" Highlight trailing spaces automatically
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=yellow guibg=yellow
match ExtraWhitespace /\s\+$/
"autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
"autocmd InsertEnter * match ExtraWhitespace /\s\+$/
"autocmd InsertLeave * match ExtraWhitespace /\s\+$/
if has('nvim')
    autocmd TermOpen * highlight ExtraWhitespace ctermbg=none guibg=none
    autocmd TermOpen * startinsert
    autocmd TermLeave * highlight ExtraWhitespace ctermbg=yellow guibg=yellow
endif

" Delete trailing whitespaces on write
function DelTrailingEmptyChars()
    let currcurpos = getcurpos()
    :%s/\s\+$//e
    call setpos('.', currcurpos)
endfunction

autocmd BufWritePre * call DelTrailingEmptyChars()
call setenv('CWRDIR', getcwd())

" Global configurations
syntax on
highlight link JavaIdentifier NONE

" Search related configs
set path=.,$MDS_ROOT,$MDS_ROOT/**,$CWRDIR,$CWRDIR/**,
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

" Editor related configs
" set cursorline
set number
set relativenumber
set mouse=ni
set showmatch
set wrap
set linebreak
set showbreak=↳
set breakindent
set scrolloff=3
set ruler
set foldmethod=indent
set nofoldenable
set hidden

" Behavior
set autochdir
set updatetime=3000
set autoread | au CursorHold,FocusGained,BufEnter * checktime
set autowrite
set noshowmode
set splitbelow
set splitright
set confirm
set completeopt=preview,menuone,noinsert,noselect

" Terminal related configs
if !has('nvim')
set term=screen-256color
endif
set encoding=UTF-8
set t_ut=
set visualbell

" Here start miscellaneous configs
set wildmenu
set wildmode=list:longest,full
set title
set backspace=indent,eol,start
set noswapfile
let g:python_highlight_all = 1

" Bind VIM clipboard registry with Linux's
"set clipboard=unnamedplus

" Add Cool status line
set laststatus=2

" Set tags location
set tags=$TAGS

if $MDS_FANCY ==? "YES"
    " I use Konsole terminal so let's add some color
    " For more info :h xterm-true-color
    if !has('nvim')
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif

    " Nice looking terminal
    set termguicolors

    " Beautiful theme
    colorscheme nightfly
    let g:lightline = { 'colorscheme': 'nightfly' }
    let g:nightflyUnderlineMatchParen = 1
    let g:nightflyCursorColor = 1
else
    colorscheme torte
    set cursorline&
endif

" Mappings
if has('nvim')
    map <F7> :FloatermSend clear && mdscode -b -n %:p -t <CR> :FloatermToggle <CR>
    map <F8> :FloatermSend clear && mdscode -b -n %:p -e <CR> :FloatermToggle <CR>
    nnoremap <silent> <C-N> :BufferNext <CR>
    nnoremap <silent> <C-P> :BufferPrevious <CR>
    nnoremap <silent> <M-{> <Cmd>BufferMovePrevious<CR>
    nnoremap <silent> <M-}> <Cmd>BufferMoveNext<CR>
    nnoremap <silent> <M-p> <Cmd>BufferPick<CR>
    nnoremap <silent> <M-f> :HopWord<CR>
    omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>
    xnoremap <silent> m :lua require('tsht').nodes()<CR>
    autocmd VimEnter * silent FloatermNew --silent
else
    map <F7> :!clear && mdscode -b -n %:p -t <CR>
    map <F8> :!clear && mdscode -b -n %:p -e <CR>
    nnoremap <C-N> :bnext <CR>
    nnoremap <C-P> :bprev <CR>
endif

map <F9> :call ToggleIOBuffers() <CR>
map <F10> :setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab smartindent <CR>
let g:floaterm_keymap_toggle = '<F12>'
let g:floaterm_height=0.9
let g:floaterm_width=0.9

map <c-h> :grep -rn $MDS_ROOT --exclude-dir=storage --exclude-dir=vendor --exclude-dir=node_modules --exclude=tags --exclude="*.json" -e
"map <C-i> :cd $MDS_ROOT <CR>
nnoremap <leader>n :NERDTreeToggle<CR>
map <F4> :TagbarToggle<CR>
nmap <C-J> :Kwbd <CR>
map <C-L> :Buffers <CR>

" Smooth scrolling
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

" Indentation character list
if ! has('nvim')
    "let g:indentLine_char_list = ['|', '¦', '┆', '┊']
    let g:indentLine_char_list = ['|']
    let g:indentLine_enabled = 1
    autocmd InsertEnter,CursorMoved *.cpp IndentLinesReset
else
    let g:indentLine_enabled = 0
endif

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

let g:trim_trailing_whitespace="true"

" netrw configurations
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
let g:netrw_winsize = 25
let g:netrw_keepdir = 0 " Netrw: keeps track of current browsing directory

" CMake configurations
let g:cmake_link_compile_commands=1
let g:cmake_default_config='build'
nmap <silent> gG :CMakeGenerate <CR>
nmap <silent> gB :CMakeBuild <CR>
nmap <silent> gc :CMakeToggle <CR>
nmap <silent> gl :CMakeClean <CR>
nmap <silent> gL :CMakeTest --output-on-failure <CR>

" Madophs defined commands
command Mdsg !mdscode -g
command Mdss !mdscode -s
command Mdsr !mdscode --exer

" Airline configurations
let g:airline#extensions#tabline#enabled = 1 "Show tabs if only one is enabled.
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'

" fzf stuff
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}, <bang>0)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

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

"command! -bang FFiles call fzf#vim#files($CWRDIR,{'options': ['--layout=reverse', '--info=inline', '--preview', 'bat {}']},<bang>0)


let g:ycm_filetype_whitelist = {'python': 1}
let g:ycm_autoclose_preview_window_after_completion = 1
let g:coc_filetypes_enable = ['c', 'cpp', 'tpp', 'javascript', 'typescript', 'php', 'bash', 'css', 'html', 'sh', 'vim', 'blade', 'gitcommit', 'rust', 'cmake', 'vim', 'lua', 'gitcommit']
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-angular', 'coc-cmake', 'coc-clangd', 'coc-css', 'coc-cssmodules', 'coc-html-css-support', 'coc-html', 'coc-htmlhint', 'coc-phpactor', 'coc-phpls', 'coc-sh', 'coc-spell-checker', 'coc-tsserver', 'coc-blade-formatter', 'coc-blade-linter', 'coc-blade','coc-pairs', 'coc-yank', 'coc-vimlsp', 'coc-rust-analyzer', 'coc-lua']
let b:coc_pairs_disabled = ['"', "'"]
let g:ycm_enabled = v:false

" Source files (Usually functions)
source $MDS_CONFIG/vim/ToggleIOBuffers.vim
source $MDS_CONFIG/vim/Kwbd.vim
source $MDS_CONFIG/vim/Coc_vs_Ycm.vim
source $MDS_CONFIG/vim/SessionManager.vim

if has('nvim')
    call setenv('VIM_EDITOR', 'nvim')
    call setenv('EDITOR_COMMAND', "nvr -cc 'FloatermHide!' {{FILE}}")
    call setenv('EDITOR_SPLIT_COMMAND', 'nvim -O2 {{FILE1}} {{FILE2}}')
    call setenv('EDITOR_DIFF_COMMAND', 'nvim -d {{FILE1}} {{FILE2}}')
else
    call setenv('VIM_EDITOR', 'vim')
endif
