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

# User VI like map keys
set -o vi

# env variables
export MDS_CONFIG=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")" | sed 's/\/mds_config.sh//g')
export MDS_INPUT=${HOME}/MdsCode/input.txt
export MDS_OUTPUT=${HOME}/MdsCode/output.txt
export MDS_SCRIPTS=${MDS_CONFIG}/scripts
export MDS_APPS=${HOME}/Documents/apps
export MDS_ASSETS=${GIT_REPOS}/assets
export MDS_HIDDEN_CONFIGS=${HOME}/.config/mdsconfig
export MDS_ROOT_FILE=${MDS_HIDDEN_CONFIGS}/.path.txt
export MDS_ROOT=$(cat ${MDS_ROOT_FILE} 2> /dev/null)
export GIT_REPOS=/home/${USER}/Documents/git
export TEST=${HOME}/Documents/test
export CTEST=${TEST}/cpp
export PY_IMG=${GIT_REPOS}/Image-Processsing/resources
export EDITOR=nvim
export PAGER=less
export LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export GREP_COLORS='ms=01;32'
export TAGS=${MDS_ROOT}/tags
export PATH=/usr/local/cuda-11.7/bin${PATH:+:${PATH}}
export PATH=${MDS_APPS}/lua-language-server/bin:${PATH}
export PATH=${GIT_REPOS}/MdsCode_Bash:${PATH}

# Small setup
source ${MDS_SCRIPTS}/shellsetup.sh
source ${MDS_SCRIPTS}/aliases.sh
source ${MDS_SCRIPTS}/zsh/zsh_plugins.sh
