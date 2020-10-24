export MDS_ROOT=/var/www/html/PsicoClinicoItsch/PsicoClinicoItsch
export GIT_REPOS=/home/$USER/Documents/git
export TAGS=$MDS_ROOT/tags
alias cpptags='cd $MDS_ROOT; rm -f tags; ctags -R --c++-kinds=+p; export TAGS=$MDS_ROOT/tags'
alias phptags='cd $MDS_ROOT; rm -f tags; ctags -R --languages=php --exclude=storage; export TAGS=$MDS_ROOT/tags'
alias setroot='export MDS_ROOT=$(pwd); export TAGS=$MDS_ROOT/tags'
alias cdr='cd $MDS_ROOT'
alias cdgit='cd $GIT_REPOS'
alias artisan='php $MDS_ROOT/artisan '
# Find files in a Laravel project in optimal way
alias mdsgrep='grep -rn . --exclude-dir=storage --exclude-dir=vendor --exclude-dir=node_modules --exclude=tags --exclude="*.json" -e' 

