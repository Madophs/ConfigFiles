export MDS_ROOT=/var/www/html/PsicoClinicoItsch/PsicoClinicoItsch

export GIT_REPOS=/home/$USER/Documents/git
export TAGS=$MDS_ROOT/tags
export TEST=$HOME/Documents/test
export CTEST=$TEST/cpp
export MDS_INPUT=$HOME/MdsCode/input.txt
export MDS_OUTPUT=$HOME/MdsCode/output.txt
export MDS_CONFIG=$GIT_REPOS/ConfigFiles
alias cpptags='cd $MDS_ROOT; rm -f tags; ctags -R --c++-kinds=+p; export TAGS=$MDS_ROOT/tags'
alias phptags='cd $MDS_ROOT; rm -f tags; ctags -R --languages=php --exclude=storage; export TAGS=$MDS_ROOT/tags'
alias setroot='export MDS_ROOT=$(pwd); export TAGS=$MDS_ROOT/tags'

# Directories aliases
alias cdr='cd $MDS_ROOT'
alias cdgit='cd $GIT_REPOS'
alias cpp='cd $CTEST'
alias cdtest='$HOME/Documents/test/'
alias artisan='php $MDS_ROOT/artisan'
alias cdhtml='/var/www/html/'
alias cddir='$HOME/Documents/'
alias cdconfig='$MDS_CONFIG'

# Find files in a Laravel project in optimal way
alias mdsgrep='grep -rn . --exclude-dir=storage --exclude-dir=vendor --exclude-dir=node_modules --exclude=tags --exclude="*.json" -e' 
alias upgrade='sudo apt update && sudo apt upgrade'

