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
    if index(g:coc_filetypes_enable, &filetype) != -1
        silent! CocEnable
        silent! CocStart

        " To code navigation.
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        "nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)
        nnoremap <C-l> :CocNext<CR>
        nnoremap <C-h> :CocPrev<CR>
        nnoremap ф :CocListResume <CR>
        " Formatting selected code.
        xmap <leader>f  <Plug>(coc-format-selected)
        nmap <leader>f  <Plug>(coc-format-selected)

        " Show functions docs using CoC
        nnoremap <silent> K :call <SID>show_documentation()<CR>

        " Make <CR> to accept selected completion item or notify coc.nvim to format
        " <C-g>u breaks current undo, please make your own choice
        inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm()
                                    \: "\<C-g>u\<TAB>"

        " Use <c-space> to trigger completion.
        if has('nvim')
            inoremap <silent><expr> <c-space> coc#refresh()
        else
            inoremap <silent><expr> <c-@> coc#refresh()
        endif

        call coc#config('html', {
            \ 'autoClosingTags': 'true',
            \ 'format.indentInnerHtml': 'true',
                \})

        " Highlight the symbol and its references when holding the cursor.
        autocmd CursorHold * silent call CocActionAsync('highlight')

    elseif(g:ycm_enabled)
        silent! CocDisable
        nmap <leader>D <plug>(YCMHover)
        nmap <silent> gd :YcmCompleter GoToDefinition <CR>
        nmap <silent> gy :YcmCompleter GetType <CR>
        nmap <silent> gi :YcmCompleter GoTo <CR>
        nmap <silent> gr :YcmCompleter GoToReferences <CR>
        nmap <silent> gk :YcmCompleter GetDoc <CR>
        let g:ycm_key_invoke_completion = '<C-Space>'
    else
        inoremap <silent><expr> <tab> pumvisible() ? coc#select_confirm() : "\<C-g>u\<tab>"
    endif
endfunction

augroup CocGroup
 autocmd!
 autocmd BufNew,BufEnter,BufAdd,BufCreate * call s:filetype_handler_for_type()
augroup end
