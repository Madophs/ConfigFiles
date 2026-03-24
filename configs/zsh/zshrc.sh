#!/bin/env zsh

trap 'eval "$(< "${MDS_TRAP_CMD}")"; truncate -s 0 "${MDS_TRAP_CMD}"' RTMIN+1

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

# Let's ignore some common commands of being registered from history
zshaddhistory() {
    # Get the command the remove the carriage return
    INPUT_COMMAND=${1%$'\n'}
    case ${INPUT_COMMAND} in
        ls|ls\ *|ll)
            return 1
            ;;
        clear)
            return 1
            ;;
        cd)
            return 1
            ;;
        loadsh|setroot)
            return 1;
    esac
    return 0;
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd print-exit-code
