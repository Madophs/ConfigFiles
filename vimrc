set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required

Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'scrooloose/nerdtree'
Plugin 'vifm/vifm.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set visualbell
set hlsearch
set autowriteall
set autoread | au CursorHold,FocusGained,BufEnter * checktime
set number
colorscheme darkblue
set autochdir
set splitbelow
set splitright
syntax on
set wildmenu
set cursorline
set autoindent
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
map <F9> :call ToggleBuffer("/home/madophs/MdsCode/input.txt","/home/madophs/MdsCode/input.txt") <CR> 
map <F6> :vertical split /home/madophs/MdsCode/input.txt<CR>:split /home/madophs/MdsCode/output.txt <CR>
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
"let g:ycm_use_clang=1
