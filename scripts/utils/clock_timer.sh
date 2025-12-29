#!/bin/bash

[[ ! -v BASH_ARGC ]] && return 0

# @brief stacks times when called
# @important "function" keyword omitted on purpose
clock_start() {
   [[ ! -v __CALLS_COUNTER ]] && declare -g -i __CALLS_COUNTER=0 # Clock counter used as varname's suffix
   [[ ! -v __CLOCK_STACK ]] && declare -g -a __CLOCK_STACK=() # Stack containing internal clocks
   declare -g -i __clock_start_${__CALLS_COUNTER}=$(( $(date +%s%N) / 1000 )) # Start time in microseconds
   __CLOCK_STACK+=( __clock_start_${__CALLS_COUNTER} )
   __CALLS_COUNTER+=1
}

# @brief computes total time spend in a function
# the result can be found in __total_spend_time in microseconds
# @important function keyword omitted on purpose
clock_end() {
    local -i __clock_end=$(( $(date +%s%N) / 1000 ))
    local __clock_start_var=${__CLOCK_STACK[-1]}
    __total_spend_time=$( echo "(${__clock_end} - ${!__clock_start_var}) / 1000000" | bc -l )
    printf -v __total_spend_time "%.6f" ${__total_spend_time}
    cout debug "Total time spend at <${YELLOW}${FUNCNAME[1]}${BLK}> is ${CYAN}${__total_spend_time}${BLK} seconds."
    unset __CLOCK_STACK[-1] # Pop last variable time as it will not be used again
}

export -f clock_start
export -f clock_end
