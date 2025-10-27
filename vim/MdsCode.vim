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
    let l:joinedArgs = join(a:000, " ")
    let l:currentBuffers = execute("buffers")
    let l:tokens = split(l:currentBuffers)
    let l:tokensLen = len(l:tokens)
    let l:i = 0
    while l:i < l:tokensLen
        " Substract filename nested in quotes
        let l:bufferStatus = l:tokens[l:i + 1]

        " Pending buffers to be saved add an extra status char, therefore adding an extra token
        if match(l:tokens[l:i + 2], '+') == 0
            let l:extraToken = 1
        else
            let l:extraToken = 0
        endif

        " Get buffer absolute filename
        let l:bufferName = fnamemodify(l:tokens[l:i + 2 + l:extraToken][1:-2], ':p')

        " Consider only buffers displayed on window
        if match(l:bufferStatus, 'a') != -1
            if MdsCodeIsFileTypeValid(l:bufferName) == 0
                execute("FloatermSend clear && mdscode -n " .. l:bufferName .. " " .. l:joinedArgs .. " || nvim --server /tmp/nvimsocket --remote-send ':FloatermShow <CR>'")
                return 0
            endif
        endif

        let l:i += 5 + l:extraToken
    endwhile
    echo "[ERROR] No valid file for building..."
    return 1
endfunction

command! -nargs=* Mdscode call g:MdsCode(<f-args>)
