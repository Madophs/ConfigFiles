if [[ ${REAL_SHELL} != zsh ]]
then
    return 0
fi

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt EXTENDED_HISTORY

function print-exit-code() {
  local -i code=$?
  if (( code )); then
    print -r -- '' ${(%):-"❌ %F{red}exit code $code%f"} ''
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd print-exit-code
