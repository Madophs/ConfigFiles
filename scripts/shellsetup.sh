#!/usr/bin/env bash

source ${MDS_SCRIPTS}/autocomplete.sh

mkdir -p ${MDS_HIDDEN_CONFIGS}
if [[ ! -f  ${MDS_ROOT_FILE} ]]
then
    touch ${MDS_ROOT_FILE}
fi

# Symbolic links
if [[ ! -h ~/.local/bin/mdssetup ]]; then
    ln -s ${MDS_SCRIPTS}/mdssetup.sh ~/.local/bin/mdssetup
fi

# Let's ignore some common commands of being registered from history
zshaddhistory() {
    # Get the command the remove the carriage return
    INPUT_COMMAND=${1%$'\n'}
    case ${INPUT_COMMAND} in
        ls|ls\ *|ll|ls\ *)
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
