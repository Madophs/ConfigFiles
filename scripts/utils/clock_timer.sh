#!/bin/bash

# @brief Stack-based execution benchmark utility for functions
# @details Provides high-precision execution metrics by only using bash primitives

declare -g -i __CALLS_COUNTER=0 # Clock counter used as varname's suffix
declare -g -a __CLOCK_STACK=() # Stack containing internal clocks
declare -g -a __CLOCK_OPERATION_STACK=() # Stack containing accumulative operation time

# @brief In case an error sabotages the clock's stack
clock_reset() {
    __CALLS_COUNTER=0
    __CLOCK_STACK=()
}

# @brief Start stack timer
# @important "function" keyword omitted on purpose
clock_start() {
    __CLOCK_STACK+=(${EPOCHREALTIME/./})
    __CLOCK_OPERATION_STACK+=(0)
}

# @brief Stop stack timer
# the result can be found in __total_spent_time in microseconds
# @important function keyword omitted on purpose
clock_end() {
    # Start of time consuming operations
    local -i __local_time_on_operation=${EPOCHREALTIME/./}

    local -i __clock_end=${EPOCHREALTIME/./}
    local -i __clock_start=${__CLOCK_STACK[-1]}
    local -i __time_on_operation=${__CLOCK_OPERATION_STACK[-1]}

    # Subtract time spent on time consuming operations
    __total_spent_time=$(( __clock_end - __clock_start - __time_on_operation ))

    printf -v __total_spent_time "%d.%6.6s" $((__total_spent_time / 1000000)) ${__total_spent_time}
    __total_spent_time=${__total_spent_time// /0}
    cout debug "Total time spent at <${YELLOW}${FUNCNAME[1]}${BLK}> is ${CYAN}${__total_spent_time}${BLK} seconds."

    # Pop stack variables, no longer useful
    unset "__CLOCK_STACK[-1]"
    unset "__CLOCK_OPERATION_STACK[-1]"

    # End of time consuming operations
    __local_time_on_operation=$(( ${EPOCHREALTIME/./} - __local_time_on_operation ))

    if (( ${#__CLOCK_STACK[@]} > 0 ))
    then
        (( __CLOCK_OPERATION_STACK[-1]+=__local_time_on_operation ))
    fi
}
