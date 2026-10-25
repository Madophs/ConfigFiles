function! g:BashAddTimeMetrics()
    let l:_ = system("sed -i '/^function/,/^}/{s/^\\(function.*\\)/\\1\\n    clock_start/g;s/^\\}/    clock_end\\n\}/g}' " .. expand('%:p'))
    execute("e %")
endfunction
command! -nargs=0 BashAddTimeMetrics call g:BashAddTimeMetrics()

function! g:BashRemoveTimeMetrics()
    let l:_ = system("sed -i '/^\\([ ]*clock_start$\\|[ ]*clock_end$\\)/d' " .. expand('%:p'))
    execute("e %")
endfunction
command! -nargs=0 BashRemoveTimeMetrics call g:BashRemoveTimeMetrics()

" Delete trailing whitespaces on write
function DelTrailingEmptyChars()
    let currcurpos = getcurpos()
    :%s/\s\+$//e
    call setpos('.', currcurpos)
endfunction

" fzf stuff
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}, <bang>0)

command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case '.fzf#shellescape(<q-args>),
    \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
