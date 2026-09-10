#!/usr/bin/env bash

function associative_array_update() {
    local ref_name=${1}
    local key=${2}
    local value=${3}
    if [[ ${REAL_SHELL} == zsh ]]
    then
        eval "${ref_name}[${key}]=\"${value}\""
    else
        local -n reference=${ref_name}
        reference["${key}"]=${value}
    fi
}

function associative_array_value() {
    local ref_name=${1}
    local key=${2}
    if [[ ${REAL_SHELL} == zsh ]]
    then
        eval echo "\$${ref_name}[${key}]"
    else
        local -n reference=${ref_name}
        echo "${reference[${key}]}"
    fi
}

# map_ref => Hashtable to hold option values
function preparse_args() {
    local map_ref=${1}
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
        parameters=( $(echo "${1}") )

        if ! echo "${parameters[*]}" | grep -E -o -q "name=.*[ \t]args=.*|args=.*[ \t]name.=*";
        then
            perror "Mandatory parameters assignments either «name» or «args» or both are missing."
        fi

        param_name=$(echo "${parameters[*]}" | grep -o -e "name=[a-zA-Z_-]\+" | awk -F '=' '{print $NF}')
        associative_array_update "${map_ref}" "main_params" \
            "$(associative_array_value "${map_ref}" main_params) ${param_name}"
        associative_array_update "${map_ref}" "${param_name}_avail" "no"
        associative_array_update "${map_ref}" "${param_name}_variants" "${param_name} --${param_name}"

        # key=value tokenization
        declare -a key_value=()
        for (( i=0; i<${#parameters[@]}; i+=1 ))
        do
            key_value=( $(echo "${parameters[@]:${i}:1}" | tr '=' ' ') )
            associative_array_update "${map_ref}" "${param_name}_${key_value[*]:0:1}" "${key_value[*]:1:1}"
        done

        # Set short and long option value entry
        associative_array_update "${map_ref}" "--${param_name}" ""
        short_option=$(echo "${parameters[*]}" | grep -o -e "short_option=[a-zA-Z_-]\+" | awk -F '=' '{print $NF}')
        if [[ -n "${short_option}" ]]
        then
            associative_array_update "${map_ref}" "${short_option}" ""
            associative_array_update "${map_ref}" "${param_name}_variants" \
                "$(associative_array_value "${map_ref}" "${param_name}_variants") ${short_option}"
        fi

        counter+=1
        shift
    done
}

function get_array_keys() {
    local array_ref=${1}
    if [[ ${REAL_SHELL} == 'zsh' ]]
    then
        echo "${(@kP)array_ref[@]}"
    else
        local -n reference=${array_ref}
        echo "${!reference[*]}"
    fi
}

function print_args() {
    local map_ref=${1}
    pinfo "Printing values"
    keys=( $(get_array_keys "${map_ref}" | tr ' ' '\n' | sort) )
    for (( i=0; i<${#keys[@]}; i+=1 ))
    do
        echo "${keys[*]:${i}:1} = $(associative_array_value "${map_ref}" "${keys[*]:${i}:1}")"
    done
}

function parse_args() {
    local map_ref=${1}
    local append_extra_args=${2} # arguments not preceding by an option (n/y)
    associative_array_update "${map_ref}" "extra" ""
    shift
    shift

    while (( $# != 0 ))
    do
        local input_param=${1}
        case ${input_param} in
            -*)
                local param_name=""
                for main_param in $(associative_array_value "${map_ref}" "main_params")
                do
                    for variant in $(associative_array_value "${map_ref}" "${main_param}_variants")
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
                    cout error "Unknown argument: ${input_param} ${main_param}"
                fi

                # Mark option as available [avail]
                associative_array_update "${map_ref}" "${param_name}_avail" "yes"

                local arg_value=''
                if [[ $(associative_array_value "${map_ref}" "${param_name}_args") == yes || $(associative_array_value "${map_ref}" "${param_name}_args") == opt ]]
                then
                    # All option's space-separated arguments
                    while [[ "${2:0:1}" != '-' && -n "${2:0:1}" ]]
                    do
                        arg_value+=$([ -z "${arg_value}" ] && echo "${2}" || echo " ${2}")
                        shift
                    done

                    if [[ -z "${arg_value}" && \
                        $(associative_array_value "${map_ref}" "${param_name}_args") == yes ]]
                    then
                        cout error "Missing value for arg «${input_param}»"
                    fi
                else
                    arg_value="yes"
                fi

                if [[ -z ${arg_value} ]]
                then
                    arg_value=$(associative_array_value "${map_ref}" "${param_name}_default")
                fi

                # Set values to params entries
                for option_param in $(associative_array_value "${map_ref}" "${param_name}_variants")
                do
                    associative_array_update "${map_ref}" "${option_param}" "${arg_value}"
                done

                shift
                ;;
            *)
                if [[ ${append_extra_args} == 'y' ]]
                then
                    local extra_value=$(associative_array_value "${map_ref}" "extra")
                    if [[ -z "${extra_value}" ]]
                    then
                        associative_array_update "${map_ref}" "extra" \
                            "${input_param}"
                    else
                        associative_array_update "${map_ref}" "extra" \
                            "$(associative_array_value "${map_ref}" "extra") ${input_param}"
                    fi
                else
                    cout error "Invalid argument: ${input_param}"
                fi
                shift
            ;;
        esac
    done

    for param_name in $(associative_array_value "${map_ref}" "main_params")
    do
        [[ -n "$(associative_array_value "${map_ref}" "${param_name}")" ]] && continue
        if [[ $(associative_array_value "${map_ref}" "${param_name}_args") == no ]]
        then
            for variant in $(associative_array_value "${map_ref}" "${param_name}_variants")
            do
                associative_array_update "${map_ref}" "${variant}" "no"
            done
        fi
    done
}

# parameter order in which options will be executed
function exec_args_flow() {
    local map_ref=${1}
    shift
    while (( $# > 0 ))
    do
        local param_name=${1}
        if [[ $(associative_array_value "${map_ref}" "${param_name}_avail") == no ]]
        then
            shift
            continue
        fi

        local func_ref=$(associative_array_value "${map_ref}" "${param_name}_function")
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
