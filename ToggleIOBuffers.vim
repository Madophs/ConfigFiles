" Function that allows me to toggle my IO files in competitive prorgramming
function! ToggleIOBuffers(inputbuffer, outputbuffer)
    let bnr = bufwinnr(a:inputbuffer)
    if bnr > 0
		:bdelete $MDS_INPUT
		:bdelete $MDS_OUTPUT
    else
		:vertical split $MDS_INPUT
		:split $MDS_OUTPUT
    endif
 endfunction

