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

call plug#end()
filetype plugin indent on

" configuration for html files
autocmd FileType html setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab

set path=.,/usr/include,$MDS_ROOT,$MDS_ROOT/**,
set hlsearch
set tabstop=4
set softtabstop=4 expandtab
set shiftwidth=4
set autoindent
set visualbell
set autoread | au CursorHold,FocusGained,BufEnter * checktime
set number
colorscheme darkblue
set autochdir
set splitbelow
set splitright
syntax on
set wildmenu
set autoindent
set autowrite
" Add Cool status line
set laststatus=2

" Set tags location
set tags=$TAGS
let g:netrw_keepdir=0 " Netrw: keeps track of current browsing directory
map <F7> :w<CR>:! clear && mdscode -b % && mdscode -rio
map <F8> :w<CR>:! clear && mdscode -rio
map <F2> :tabp <CR>
map <F3> :tabn <CR>
function! ToggleBuffer(inputbuffer, outputbuffer)
    let bnr = bufwinnr(a:inputbuffer)
    if bnr > 0
		:bdelete /home/madophs/MdsCode/input.txt
		:bdelete /home/madophs/MdsCode/output.txt

    else
		:vertical split /home/madophs/MdsCode/input.txt
		:split /home/madophs/MdsCode/output.txt
    endif
 endfunction

"map <F9> :tabnew /home/madophs/MdsCode/input.txt<CR>:vsplit /home/madophs/MdsCode/output.txt<CR>
map <c-f> :grep -rn $MDS_ROOT --exclude-dir=storage --exclude-dir=vendor --exclude-dir=node_modules --exclude=tags --exclude="*.json" -e
map <F9> :call ToggleBuffer("/home/madophs/MdsCode/input.txt","/home/madophs/MdsCode/input.txt") <CR> 
map <F6> :vertical split /home/madophs/MdsCode/input.txt<CR>:split /home/madophs/MdsCode/output.txt <CR>
map <C-i> :cd $ROOT <CR>
nmap <C-V> "+gP
map <C-n> :NERDTreeToggle<CR>
nnoremap <M-Right> <C-w>l
nnoremap <M-Left> <C-w>h
nnoremap <M-Down> <C-w>j
nnoremap <M-Up> <C-w>k
"let g:ycm_global_ycm_extra_conf = '$HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'
let NERDTreeShowHidden=1
" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
let g:ycm_autoclose_preview_window_after_completion=1
"let g:ycm_show_diagnostics_ui = 0
let g:ycm_use_clang=1
let root="/var/www/html/CiudadDelNino/ciudad_del_nino"
" Let clangd fully control code completion
let g:ycm_clangd_uses_ycmd_caching = 0
" Use installed clangd, not YCM-bundled clangd which doesn't get updates.
let g:ycm_clangd_binary_path = exepath("clangd")
