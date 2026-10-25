" Function that allows me to toggle my IO files in competitive programming
function! ToggleIOBuffers()
    let bnr = bufwinnr($MDS_INPUT)
    if bnr > 0
		bdelete input
		bdelete output
    else
        let l:currwin = win_getid()
        let l:newwinwidth = (winwidth(0) / 4)
        vertical split $MDS_INPUT
        split $MDS_OUTPUT
        execute 'vertical resize ' l:newwinwidth
        call win_gotoid(l:currwin)
    endif
 endfunction

