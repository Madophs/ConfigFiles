let g:startify_session_dir = $MDS_SESSIONS_DIR

function! g:SaveSession()
    let l:wins2close = ['NERD_tree_', '__Tagbar__']
    for item in l:wins2close
        let l:winnr2id = win_getid(bufwinnr(item))
        if l:winnr2id != 0
            call win_execute(l:winnr2id, 'quit')
        endif
    endfor
    let g:mds_session_file = system("(REPONAME=$(git rev-parse --show-toplevel 2> /dev/null) && echo $REPONAME | awk -F '/' '{print \"git_\"$NF\".vim\"}') || echo " .. getcwd() .. " | awk -F '/' '{print $NF\".vim\"}'")
    let l:save_session_path = $MDS_SESSIONS_DIR .. '/' .. g:mds_session_file
    execute "mksession!" .. l:save_session_path
endfunction

function! g:LoadSession(...)
    let g:mds_session_file = a:0 > 0 ? a:1 : ''
    if g:mds_session_file == ''
        let g:mds_session_file = system("(REPONAME=$(git rev-parse --show-toplevel 2> /dev/null) && echo $REPONAME | awk -F '/' '{print \"git_\"$NF\".vim\"}') || echo " .. getcwd() .. " | awk -F '/' '{print $NF\".vim\"}'")
    endif
    let l:save_session_path = $MDS_SESSIONS_DIR .. '/' .. g:mds_session_file
    execute "silent! source " .. l:save_session_path
endfunction

command! SMake call g:SaveSession()
autocmd VimEnter * command! -nargs=* SLoad call g:LoadSession(<f-args>)
