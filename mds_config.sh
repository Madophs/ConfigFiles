# Shell configurations
HISTSIZE=3000
HISTFILESIZE=3000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt EXTENDED_HISTORY

# env variables
export GIT_REPOS=/home/$USER/Documents/git
export TEST=$HOME/Documents/test
export CTEST=$TEST/cpp
export MDS_INPUT=$HOME/MdsCode/input.txt
export MDS_OUTPUT=$HOME/MdsCode/output.txt
export MDS_CONFIG=$GIT_REPOS/ConfigFiles
export MDS_SCRIPTS=$MDS_CONFIG/scripts
export MDS_APPS=$HOME/Documents/apps
export PY_IMG=$GIT_REPOS/Image-Processsing/resources
export EDITOR=vim
export PAGER=less
export MDS_ASSETS=$GIT_REPOS/assets
export PATH=/usr/local/cuda-11.4/bin${PATH:+:${PATH}}
export PATH=$GIT_REPOS/MdsCode_Bash:${PATH}
export LD_LIBRARY_PATH=/usr/local/cuda-11.4/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export GREP_COLORS='ms=01;32'

# Small setup
. $MDS_CONFIG/scripts/setup.sh
. $MDS_CONFIG/scripts/plugins_enabled_default.sh

# User configs (overrides default ones)
if [[ -f $MDS_CONFIG/scripts/plugins_enabled_user.sh ]]; then
    source $MDS_CONFIG/scripts/plugins_enabled_user.sh
fi

# User VI like map keys
set -o vi

export MDS_ROOT=$(cat $MDS_CONFIG/.path.txt)
export TAGS=$MDS_ROOT/tags

# Directories aliases
alias cdr='$MDS_ROOT'
alias cdgit='$GIT_REPOS'
alias lcpp='$GIT_REPOS/C-CPP-Linux-Programming'
alias cpp='$CTEST'
alias cdtest='$HOME/Documents/test/'
alias artisan='php $MDS_ROOT/artisan'
alias cdhtml='/var/www/html/'
alias cddir='$HOME/Documents/'
alias cdconfig='$MDS_CONFIG'
alias cdscripts='$MDS_SCRIPTS'
alias cdw='$HOME/Downloads'
alias cdd='$HOME/Documents'
alias cdapps='$MDS_APPS'

#command aliases
alias cpptags='cd $MDS_ROOT; rm -f tags; ctags -R --c++-kinds=+p; export TAGS=$MDS_ROOT/tags'
alias phptags='cd $MDS_ROOT; rm -f tags; ctags -R --languages=php --exclude=storage; export TAGS=$MDS_ROOT/tags'
alias setroot='echo $(pwd) > $MDS_CONFIG/.path.txt; export MDS_ROOT=$(cat $MDS_CONFIG/.path.txt) ; export TAGS=$MDS_ROOT/tags'
alias getroot='export MDS_ROOT=$(cat $MDS_CONFIG/.path.txt); echo $MDS_ROOT'
alias upgrade='sudo apt update && sudo apt upgrade -y'
alias update='sudo apt update'
alias install='sudo apt install'
alias autoremove='sudo apt autoremove'
alias remove='sudo apt remove'
alias show='sudo apt show'
alias search='sudo apt search'
alias loadsh='source ~/.zshrc'
alias zshlogin='exec zsh --login'
alias myip='host myip.opendns.com resolver1.opendns.com'
alias vimrc='vim $MDS_CONFIG/vimrc'
alias config='vim $MDS_CONFIG'
alias kc='kubectl'
alias mm='mdscode -f cpp -t -n'
alias mb='mdscode -b'
alias me='mdscode -e'

# Scripts aliases
alias operaffmpeg='$MDS_CONFIG/scripts/operaffmpeg.sh'
alias zshplugins='$MDS_CONFIG/scripts/zsh_plugins.sh'
alias sl2='$MDS_CONFIG/scripts/backup_steam_savefiles.sh'
alias htoken='$MDS_CONFIG/scripts/handle_git_token.sh'
alias mdsetup='$MDS_SCRIPTS/mdsetup.sh'
alias gclone='$MDS_SCRIPTS/git.sh clone'
alias gpush='$MDS_SCRIPTS/git.sh push'
alias gfetch='$MDS_SCRIPTS/git.sh fetch'

# Plugins
if [[ -e $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -e $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [[ -e ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh ]]; then
    source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh
    znt_list_instant_select=1
    znt_list_border=0
    znt_list_bold=1
    znt_list_colorpair="green/black"
    znt_functions_keywords=( "zplg" "zgen" "match"  )
    znt_cd_active_text="underline"
    znt_env_nlist_coloring_color=$'\x1b[00;33m'
    znt_cd_hotlist=( "~/.config/znt" "/usr/share/zsh/site-functions" "/usr/share/zsh"
                    "/usr/local/share/zsh/site-functions" "/usr/local/share/zsh"
                                    "/usr/local/bin" )
fi
