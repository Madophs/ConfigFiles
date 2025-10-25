function! MdsCodeIsFileTypeValid(filename)
    let l:validFiletypes = ["cpp", "java", "py", "rs", "c"]
    let l:filetype = split(a:filename, "\\.")[-1]
    for l:item in l:validFiletypes
        if l:filetype == l:item
            return 0
        endif
    endfor
    return -1
endfunction

function! g:MdsCode(...)
    let l:joined_args = join(a:000, " ")
    let l:currentBuffers = execute("buffers")
    let l:tokens = split(l:currentBuffers)
    let l:tokensLen = len(l:tokens)
    let l:i = 0
    while l:i < l:tokensLen
        " Substract filename nested in quotes
        let l:bufferStatus = l:tokens[l:i + 1]

        " Get buffer absolute filename
        let l:bufferName = fnamemodify(l:tokens[l:i + 2][1:-2], ':p')

        " Consider only buffers displayed on window
        if match(l:bufferStatus, 'a') != -1
            if MdsCodeIsFileTypeValid(l:bufferName) == 0
                execute("FloatermSend clear && mdscode -n " .. l:bufferName .. " " .. l:joined_args .. " || nvim --server /tmp/nvimsocket --remote-send ':FloatermShow <CR>'")
                return 0
            endif
        endif

        let l:i += 5
    endwhile
    echo "[ERROR] No valid file for building..."
    return 1
endfunction

command! -nargs=* Mdscode call g:MdsCode(<f-args>)
