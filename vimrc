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

call plug#end()
filetype plugin indent on

" configuration for html files
autocmd FileType html setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab

" Set the working directory to the current's file directory
" Issues with terminal buffer
" autocmd BufEnter * lcd %:p:h

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
colorscheme molokai
syntax on
set path=.,$MDS_ROOT,$MDS_ROOT/**,
set hlsearch
set incsearch
set tabstop=4
set softtabstop=4 expandtab
set shiftwidth=4
set autoindent
set visualbell
set autoread | au CursorHold,FocusGained,BufEnter * checktime
set number
set autochdir
set splitbelow
set splitright
set wildmenu
set relativenumber
set wildmode=list:longest,full
set autoindent
set autowrite
set cursorline
set showmatch
set encoding=UTF-8
set term=screen-256color
set t_ut=
set noshowmode
set updatetime=3000
set mouse=ni

" Bind VIM clipboard registry with Linux's
set clipboard=unnamedplus

" Add Cool status line
set laststatus=2

" Set tags location
set tags=$TAGS

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
map <F4> :TagbarToggle<CR>
nnoremap <M-Right> <C-w>l
nnoremap <M-Left> <C-w>h
nnoremap <M-Down> <C-w>j
nnoremap <M-Up> <C-w>k
map <C-k> :Kwbd <CR>
map <C-L> :Buffers <CR>

" NERDTree configurations
let g:netrw_keepdir=0 " Netrw: keeps track of current browsing directory
let NERDTreeShowHidden=1

" YouCompleteme configuration
"let g:ycm_global_ycm_extra_conf = '$HOME/.vim/plugged/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_completion=1
"let g:ycm_show_diagnostics_ui = 0
let g:ycm_use_clang=1
" Let clangd fully control code completion
let g:ycm_clangd_uses_ycmd_caching = 0
" Use installed clangd, not YCM-bundled clangd which doesn't get updates.
let g:ycm_clangd_binary_path = exepath("clangd")
let g:trim_trailing_whitespace="true"

" fzf stuff
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}, <bang>0)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)


let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_enabled = 1

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
