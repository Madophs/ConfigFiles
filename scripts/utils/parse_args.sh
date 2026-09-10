#!/usr/bin/env bash

# map_ref => Hashtable to hold option values
function preparse_args() {
    declare -n map_ref=${1}
    declare -i counter=1
    shift

    if ! echo "$*" | grep -E -o -q '^([a-z_]+=[a-zA-Z0-9_-]+[ \t]+)+[a-z_]+=[a-zA-Z0-9_-]+$';
    then
        perror "Invalid format for parameter's assignments. Format: parameter=value"
    fi

    declare -a parameters=()
    local param_name short_option
    while (( $# != 0 ))
    do
        parameters=( ${ echo "${1}"; } )

        if ! echo "${parameters[*]}" | grep -E -o -q "name=.*[ \t]args=.*|args=.*[ \t]name.=*";
        then
            perror "Mandatory parameters assignments either «name» or «args» or both are missing."
        fi

        param_name=$(echo "${parameters[*]}" | grep -o -e "name=[a-zA-Z_-]\+" | awk -F '=' '{print $NF}')
        map_ref["main_params"]+="${param_name} "
        map_ref["${param_name}_avail"]=no
        map_ref["${param_name}_params"]="${param_name} --${param_name}"

        # key=value tokenization
        declare -a key_value=()
        for (( i=0; i<${#parameters[@]}; i+=1 ))
        do
            mapfile -t key_value < <(echo "${parameters[@]:${i}:1}" | tr '=' '\n')
            map_ref["${param_name}_${key_value[@]:0:1}"]="${key_value[*]:1:1}"
        done

        # Set short and long option value entry
        map_ref["--${param_name}"]=""
        short_option=$(echo "${parameters[*]}" | grep -o -e "short_option=[a-zA-Z_-]\+" | awk -F '=' '{print $NF}')
        if [[ -n "${short_option}" ]]
        then
            map_ref["${short_option}"]=""
            map_ref["${param_name}_params"]+=" ${short_option}"
        fi

        counter+=1
        shift
    done
}

function get_array_keys() {
    declare -n array_ref=${1}
    if [[ ${REAL_SHELL} == 'zsh' ]]
    then
        echo "${(@k)array_ref}"
    else
        echo ${!array_ref[@]}
    fi
}

function print_args() {
    local -n map_ref=${1}
    pinfo "Printing values"
    mapfile -t keys < <( get_array_keys map_ref | tr ' ' '\n' | sort )
    for (( i=0; i<${#keys[@]}; i+=1 ))
    do
        echo "${keys[*]:${i}:1} = ${map_ref[${keys[@]:${i}:1}]}"
    done
}

function parse_args() {
    local -n map_ref=${1}
    local append_extra_args=${2} # arguments not preceding by an option (n/y)
    map_ref["extra"]=""
    shift
    shift

    while (( $# != 0 ))
    do
        local input_param=${1}
        case ${input_param} in
            -*)
                local param_name=""

                for main_param in ${map_ref["main_params"]}
                do
                    for variant in ${map_ref["${main_param}_params"]}
                    do
                        if [[ "${input_param}" == "${variant}" ]]
                        then
                            param_name="${main_param}"
                            break
                        fi
                    done
                    [[ -n "${param_name}" ]] && break
                done

                # Check if option (key) is present in map
                if [[ -z "${param_name}" ]]
                then
                    cout error "Unknown argument: ${input_param}"
                fi

                # Mark option as available [avail]
                map_ref["${param_name}_avail"]=yes

                local arg_value=''
                if [[ ${map_ref["${param_name}_args"]} == yes || ${map_ref["${param_name}_args"]} == opt ]]
                then
                    # All option's space-separated arguments
                    while [[ "${2:0:1}" != '-' && -n "${2:0:1}" ]]
                    do
                        arg_value+=$([ -z "${arg_value}" ] && echo "${2}" || echo " ${2}")
                        shift
                    done

                    if [[ -z "${arg_value}" && ${map_ref["${param_name}_args"]} == yes ]]
                    then
                        cout error "Missing value for arg «${input_param}»"
                    fi
                else
                    arg_value="yes"
                fi

                if [[ -z ${arg_value} ]]
                then
                    arg_value=${map_ref["${param_name}_default"]}
                fi

                # Set values to params entries
                for option_param in ${map_ref[${param_name}_params]}
                do
                    map_ref["${option_param}"]="${arg_value}"
                done

                shift
                ;;
            *)
                if [[ ${append_extra_args} == 'y' ]]
                then
                    map_ref["extra"]+="${input_param} "
                else
                    cout error "Invalid argument: ${input_param}"
                fi
                shift
            ;;
        esac
    done

    for param_name in ${map_ref["main_params"]}
    do
        [[ -n ${map_ref["${param_name}"]} ]] && continue
        if [[ ${map_ref["${param_name}_args"]} == no ]]
        then
            for variant in ${map_ref["${param_name}_params"]}
            do
                map_ref["${variant}"]=no
            done
        fi
    done
}

# parameter order in which options will be executed
function exec_args_flow() {
    local -n map_ref=${1}
    shift
    while (( $# > 0 ))
    do
        local param_name=${1}

        if [[ ${map_ref["${param_name}_avail"]} == NO ]]
        then
            shift
            continue
        fi

        local func_ref=${map_ref["${param_name}_function"]}
        if [[ -n "${func_ref}" ]]
        then
            ${func_ref} map_ref
        fi
        shift
    done
}

#function func_t() {
    #echo -n "function [func_t] -t value is ${map["title"]} create value is ${map["create"]}"
#}

#function func_run() {
    #echo "function [func_run] -r value is ${map["-r"]}"
#}

#function some_main() {
    #local -A map
    #preparse_args map \
        #"name=title     args=yes    short_option=-t     function=func_t" \
        #"name=run       args=no     short_option=-r     function=func_run" \
        #"name=file      args=opt    short_option=-f     default=default_file" \
        #"name=create    args=no"

    #parse_args map y "${@}"
    #print_args map
    #exec_args_flow map title run
#}

#some_main some values -t title_value -f --run
