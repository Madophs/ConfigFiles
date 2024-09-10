function! g:CwdTrap()
    call system("echo \"" .. getcwd() .. "\" > $MDS_TRAP_CMD")
endfunction

command! CwdTrap call g:CwdTrap()
