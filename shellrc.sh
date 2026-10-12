# Current shell PID
declare -i SHELL_PID
SHELL_PID="$(ps -opid $$ | tail -n 1)"

# compute base directory
REAL_SHELL="$(ps -o command $$ | tail -n 1 | awk '{print $0}' \
              | grep -o -e '^[\/a-z-][/a-z]\+' | awk -F '[/-]' '{print $NF}')"
if [[ $REAL_SHELL == zsh ]]
then
    MDS_CONFIG=$(cd -P -- "$(dirname -- "$0")" \
                 && printf '%s\n' "$(pwd -P)/$(basename -- "$0")" | sed 's/\/shellrc\.sh//g')
else
    MDS_CONFIG="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fi

# common env variables
source "${MDS_CONFIG}/configs/shellenv.sh"

# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# Small setup
source "${MDS_CONFIG}/scripts/utils/cout.sh"
source "${MDS_CONFIG}/configs/shellsetup.sh"

# function commands
source "${MDS_CONFIG}/scripts/custom_cmds.sh"
