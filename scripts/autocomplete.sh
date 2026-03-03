# python3 -m pip install argcomplete
if [[ ${REAL_SHELL} == zsh ]]
then
    autoload bashcompinit
    bashcompinit
fi

if [[ -f "/etc/bash_completion" && ${REAL_SHELL} == "bash" ]]
then
    source "/etc/bash_completion"
fi

function load_autocomplete_resource() {
    if [[ -h /etc/bash_completion.d/$1 ]]
    then
        source /etc/bash_completion.d/$1
    fi
}

load_autocomplete_resource mdscode-prompt
load_autocomplete_resource mdssetup-prompt
