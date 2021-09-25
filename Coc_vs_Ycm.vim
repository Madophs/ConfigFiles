function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:filetype_handler_for_type()
  if index(g:coc_filetypes_enable, &filetype) == -1
    silent! CocDisable
    nmap <leader>D <plug>(YCMHover)
    nmap <silent> gd :YcmCompleter GoToDefinition <CR>
    nmap <silent> gy :YcmCompleter GetType <CR>
    nmap <silent> gi :YcmCompleter GoTo <CR>
    nmap <silent> gr :YcmCompleter GoToReferences <CR>
    nmap <silent> gk :YcmCompleter GetDoc <CR>
    let g:ycm_key_invoke_completion = '<C-Space>'
  else
    silent! CocEnable

    " To code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Formatting selected code.
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    " Show functions docs using CoC
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    " Use <c-space> to trigger completion.
    if has('nvim')
        inoremap <silent><expr> <c-space> coc#refresh()
    else
        inoremap <silent><expr> <c-@> coc#refresh()
    endif

    " Make <CR> auto-select the first completion item and notify coc.nvim to
    " format on enter, <cr> could be remapped by other vim plugin
    inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    " Use tab for trigger completion with characters ahead and navigate.
    " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
    " other plugin before putting this into your config.
    inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    call coc#config('html', {
        \ 'autoClosingTags': 'true',
        \ 'format.indentInnerHtml': 'true',
            \})

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
  endif
endfunction

augroup CocGroup
 autocmd!
 autocmd BufNew,BufEnter,BufAdd,BufCreate * call s:filetype_handler_for_type()
augroup end
