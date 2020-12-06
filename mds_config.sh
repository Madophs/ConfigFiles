# Shell configurations
HISTSIZE=3000
HISTFILESIZE=3000
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# env variables
export GIT_REPOS=/home/$USER/Documents/git
export TEST=$HOME/Documents/test
export CTEST=$TEST/cpp
export MDS_INPUT=$HOME/MdsCode/input.txt
export MDS_OUTPUT=$HOME/MdsCode/output.txt
export MDS_CONFIG=$GIT_REPOS/ConfigFiles

# Small setup
. $MDS_CONFIG/scripts/setup.sh
# User VI like map keys
set -o vi

export MDS_ROOT=`cat $MDS_CONFIG/.path.txt`
export TAGS=$MDS_ROOT/tags

# Directories aliases
alias cdr='cd $MDS_ROOT'
alias cdgit='cd $GIT_REPOS'
alias cpp='cd $CTEST'
alias cdtest='$HOME/Documents/test/'
alias artisan='php $MDS_ROOT/artisan'
alias cdhtml='/var/www/html/'
alias cddir='$HOME/Documents/'
alias cdconfig='$MDS_CONFIG'
alias cdw='$HOME/Downloads'
alias cdd='$HOME/Documents'

#command aliases
alias cpptags='cd $MDS_ROOT; rm -f tags; ctags -R --c++-kinds=+p; export TAGS=$MDS_ROOT/tags'
alias phptags='cd $MDS_ROOT; rm -f tags; ctags -R --languages=php --exclude=storage; export TAGS=$MDS_ROOT/tags'
alias setroot='echo $(pwd) > $MDS_CONFIG/.path.txt; export MDS_ROOT=`cat $MDS_CONFIG/.path.txt`; export TAGS=$MDS_ROOT/tags'
alias upgrade='sudo apt update && sudo apt upgrade'
alias update='sudo apt update'
alias install='sudo apt install'
alias autoremove='sudo apt autoremove'
alias show='sudo apt show'
alias loadsh='source ~/.zshrc'

# Scripts aliases
alias operaffmpeg='$MDS_CONFIG/scripts/operaffmpeg.sh'
