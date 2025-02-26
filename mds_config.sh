# We can only return from a function or sourced script
(return 0 2>/dev/null) && declare -g IS_SOURCED=YES || declare -g IS_SOURCED=NO

# Current shell PID
declare -g -i SHELL_PID=$(ps -opid $$ | tail -n 1)

# compute base directory
declare -g REAL_SHELL=$(ps -o command $$ | tail -n 1 | awk '{print $0}' | grep -o -e '^[\/a-z]\+' | awk -F '/' '{print $NF}')
if [[ ${REAL_SHELL} == zsh ]]
then
    export MDS_CONFIG=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")" | sed 's/\/mds_config\.sh//g')
else
    export MDS_CONFIG="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fi

# env variables
export SHELL_PID
export MDS_SCRIPTS=${MDS_CONFIG}/scripts
export MDS_APPS=${HOME}/Documents/apps
export MDS_ASSETS=${GIT_REPOS}/assets
export MDS_HIDDEN_CONFIGS=${HOME}/.config/mdsconfig
export MDS_SESSIONS_DIR=${HOME}/.config/mdsconfig/sessions
export MDS_ROOT_FILE=${MDS_HIDDEN_CONFIGS}/.path.txt
export MDS_ROOT=$(cat ${MDS_ROOT_FILE} 2> /dev/null)
export MDS_TRAP_CMD=${MDS_HIDDEN_CONFIGS}/mds_trap_cmd
export MDS_INPUT=${HOME}/.local/share/mdscode/io/input
export MDS_OUTPUT=${HOME}/.local/share/mdscode/io/output
export MDS_FANCY=YES
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
export PATH=${HOME}/.local/bin:${PATH}
export PATH=${MDS_APPS}/lua-language-server/bin:${PATH}
export PATH=${GIT_REPOS}/MdsCode_Bash:${PATH}
export APPCWD=/tmp/appcwd
unset SSH_ASKPASS

# Small setup
source ${MDS_SCRIPTS}/zsh/configs.sh
source ${MDS_SCRIPTS}/shellsetup.sh
source ${MDS_SCRIPTS}/aliases.sh
source ${MDS_SCRIPTS}/zsh/zsh_plugins.sh

# function commands
source ${MDS_SCRIPTS}/custom_cmds.sh
