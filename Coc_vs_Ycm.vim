function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
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
  else
    silent! CocEnable

    " To code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Show functions docs using CoC
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
  endif
endfunction

augroup CocGroup
 autocmd!
 autocmd BufNew,BufEnter,BufAdd,BufCreate * call s:filetype_handler_for_type()
augroup end
