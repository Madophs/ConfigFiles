#!/bin/bash

source ${MDS_SCRIPTS}/common.sh

function preparse_args() {
    declare -n map_ref=${1}
    shift
    while (( $# != 0 ))
    do
        declare -a arr=($(echo ${1}))
        local prefix=$(echo "${arr[*]}" | grep -o -e 'prefix=[a-zA-Z_-]\+' | awk -F '=' '{print $NF}')
        for (( i=0; i<${#arr[@]}; i+=1 ))
        do
            declare -a tmp=( $(echo ${arr[${i}]} | tr '=' ' ') )
            if [[ ${tmp:0:1} != '-' && -n "${prefix}" ]]
            then
                map_ref["${prefix}_${tmp[0]}"]="${tmp[1]}"
            else
                map_ref["${tmp[0]}"]="${tmp[1]}"
            fi
        done

        shift
    done

}

function print_args() {
    declare -n map_ref=${1}
    cout info printing values
    local keys=(${!map_ref[*]})
    for (( i=0; i<${#keys[@]}; i+=1 ))
    do
        echo ${keys[i]} ${map_ref["${keys[${i}]}"]}
    done
}

function parse_args() {
    declare -n map_ref=${1}
    local append_extra_args=${2} # arguments not preceeding an option (n/y)
    shift
    shift

    while (( $# != 0 ))
    do
        local argval=${1}
        case ${argval} in
            -*|--*)
                if [[ "${argval:0:2}" == '--' && -n "${map_ref[${argval}]}" ]]
                then
                    argval="${map_ref[${argval}]}"
                fi

                if [[ -n ${map_ref[${argval}_prefix]} ]]
                then
                    local arg_value=''
                    if [[ ${map_ref[${argval}_args]} == yes ]]
                    then
                        while [[ "${2:0:1}" != '-' && -n "${2:0:1}" ]]
                        do
                            arg_value+=$([ -z "${arg_value}" ] && echo "${2}" || echo " ${2}")
                            shift
                        done

                        if [[ -z ${arg_value} ]]
                        then
                            cout error "Missing value for arg \"${argval}\""
                        fi
                    else
                        arg_value='YES'
                    fi

                    map_ref["${argval}"]=${arg_value}
                else
                    cout error "Unknown argument: ${argval}"
                fi
                shift
                ;;
            *)
                if [[ ${append_extra_args} == 'y' ]]
                then
                    map_ref["extra"]+="${argval} "
                else
                    cout error "Invalid argument: ${argval}"
                fi
                shift
            ;;
        esac
    done
}

function exec_args_flow() {
    declare -n map_ref=${1}
    shift
    while (( $# > 0 ))
    do
        local func_ref=${map_ref[${1}_func]}
        if [[ -n "${func_ref}" ]]
        then
            ${func_ref}
        fi
        shift
    done
}

#function func_t() {
    #echo "hi i'm in the function T"
#}

#function func_run() {
    #echo "About to run the file"
    #cout info -f value is ${map["-f"]}
#}

#function some_main() {
    #declare -A map
    #preparse_args map \
        #"args=yes prefix=-t func=func_t --title=-t" \
        #"args=no func=func_run prefix=-r --run=-r" \
        #"args=yes prefix=-f --file=-f"

    #parse_args map y "${@}"
    #exec_args_flow map -t -r
    #print_args map
#}

#some_main some values -t title_value -f "filename" --run end
