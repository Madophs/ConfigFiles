function! g:BashAddTimeMetrics()
    let l:_ = system("sed -i '/^function/,/^}/{s/^\\(function.*\\)/\\1\\nclock_start/g;s/^\\}/clock_end\\n\}/g}' " .. expand('%:p'))
    execute("e %")
endfunction
command! -nargs=0 BashAddTimeMetrics call g:BashAddTimeMetrics()

function! g:BashRemoveTimeMetrics()
    let l:_ = system("sed -i '/^\\([ ]*clock_start$\\|[ ]*clock_end$\\)/d' " .. expand('%:p'))
    execute("e %")
endfunction
command! -nargs=0 BashRemoveTimeMetrics call g:BashRemoveTimeMetrics()
