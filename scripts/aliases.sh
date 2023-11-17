# Directories aliases
alias cdr="cd ${MDS_ROOT}"
alias cdgit="cd ${GIT_REPOS}"
alias lcpp="cd ${GIT_REPOS}/C-CPP-Linux-Programming"
alias cpp="cd ${CTEST}"
alias cdtest="cd ${TEST}"
alias artisan="php ${MDS_ROOT}/artisan"
alias cdhtml="cd /var/www/html/"
alias cddir="cd ${HOME}/Documents/"
alias cdconfig="cd ${MDS_CONFIG}"
alias cdscripts="cd ${MDS_SCRIPTS}"
alias cdw="cd ${HOME}/Downloads"
alias cdd="cd ${HOME}/Documents"
alias cdapps="cd ${MDS_APPS}"

#command aliases
alias cpptags="cd ${MDS_ROOT}; rm -f tags; ctags -R --c++-kinds=+p; export TAGS=${MDS_ROOT}/tags"
alias phptags="cd ${MDS_ROOT}; rm -f tags; ctags -R --languages=php --exclude=storage; export TAGS=${MDS_ROOT}/tags"
alias setroot="echo \$(pwd) > ${MDS_ROOT_FILE}; export MDS_ROOT=\$(cat ${MDS_ROOT_FILE}); export TAGS=${MDS_ROOT}/tags"
alias getroot="export MDS_ROOT=$(cat ${MDS_CONFIG}/.path.txt); echo ${MDS_ROOT}"
alias upgrade="sudo apt update && sudo apt upgrade -y"
alias update="sudo apt update"
alias install="sudo apt install"
alias reinstall="sudo apt reinstall"
alias purge="sudo apt purge"
alias autoremove="sudo apt autoremove"
alias remove="sudo apt remove"
alias show="sudo apt show"
alias search="sudo apt search"
alias loadsh="source ~/.zshrc"
alias zshrc="${EDITOR} ~/.zshrc"
alias zshlogin="exec zsh --login"
alias off="shutdown now"
alias myip="host myip.opendns.com resolver1.opendns.com"
alias vimrc="${EDITOR} ${MDS_CONFIG}/vimrc"
alias config="${EDITOR} ${MDS_CONFIG}"
alias mm="mdscode -f cpp -t -n"
alias mb="mdscode -b"
alias me="mdscode -e"
alias vimc="vim --servername Competitive --remote-silent "

# Scripts aliases
alias operaffmpeg="${MDS_SCRIPTS}/operaffmpeg.sh"
alias zshplugins="${MDS_SCRIPTS}/zsh/zsh_plugins_setup.sh"
alias sl2="${MDS_SCRIPTS}/backup_steam_savefiles.sh"
alias htoken="${MDS_SCRIPTS}/handle_git_token.sh"
alias gclone="${MDS_SCRIPTS}/git.sh clone"
alias gpush="${MDS_SCRIPTS}/git.sh push"
alias gpull="${MDS_SCRIPTS}/git.sh pull"
alias gfetch="${MDS_SCRIPTS}/git.sh fetch"
alias pdir="source ${MDS_SCRIPTS}/zsh/hotlist.sh; push_directory_to_hotlist \$(pwd)"
alias rdir="source ${MDS_SCRIPTS}/zsh/hotlist.sh; remove_directory_from_hotlist \$(pwd)"

if [[ -x $(which minikube) ]]
then
    alias kc='minikube kubectl --'
    alias kcip='minikube ip'
else
    alias kc='kubectl'
fi

# Credits: https://github.com/Peltoche/lsd
if [[ -f $(which lsd) ]]; then
    alias ll='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
fi
