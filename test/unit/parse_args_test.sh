#!/bin/env bash


source ../../scripts/utils/cout.sh
source ../../scripts/common.sh
source ../../scripts/utils/parse_args.sh

MDS_STACKTRACE_ENABLED=NO

function test_preparse_mandatory_args() {
    local -A map
    # Missing name parameter
    (preparse_args map \
        "args=yes    short_option=-t     function=func_t")
    fwktest_assert_exit_code_equals $? 1

    # Missing arg parameter
    (preparse_args map \
        "name=title args    short_option=-t     function=func_t")
    fwktest_assert_exit_code_equals $? 1

    # Correct one
    (preparse_args map \
        "name=title args=opt short_option=-t     function=func_t")
    fwktest_assert_exit_code_equals $? 0
}

function test_preparse_parameters_format() {
    local -A map
    (preparse_args map \
        "name=title     args=yes    short_option=-t     function=func_t" \
        "name=run       args=no     short_option=-r     function=func_run" \
        "name=file      args=opt    short_option     default=default_file" \
        "name=create    args=no")
    fwktest_assert_exit_code_equals $? 1

    (preparse_args map \
        "name=title     args=yes    short_option=-t     function=func_t" \
        "name=run       args=no     short_option=-r     function=func_run" \
        "name=file      args=opt    short_option=-f     default=default_file" \
        "name=create    args=no")
    fwktest_assert_exit_code_equals $? 0
}

function test_preparse_check_populated_values() {
    local -A map

    preparse_args map \
        "name=title     args=yes    short_option=-t     function=func_t" \
        "name=run       args=no     short_option=-r     function=func_run" \
        "name=file      args=opt    short_option=-f     default=default_file" \
        "name=create    args=no"
    parse_args map y -t my_title -f --run

    fwktest_assert_string_equals "${map["title"]}" "my_title"
    fwktest_assert_string_equals "${map["--title"]}" "my_title"
    fwktest_assert_string_equals "${map["-t"]}" "my_title"
    fwktest_assert_string_equals "${map["title_args"]}" "yes"

    fwktest_assert_string_equals "${map["file"]}" "default_file"
    fwktest_assert_string_equals "${map["--file"]}" "default_file"
    fwktest_assert_string_equals "${map["-f"]}" "default_file"
    fwktest_assert_string_equals "${map["file_args"]}" "opt"
    fwktest_assert_string_equals "${map["file_avail"]}" "yes"


    fwktest_assert_string_equals "${map["run"]}" "yes"
    fwktest_assert_string_equals "${map["--run"]}" "yes"
    fwktest_assert_string_equals "${map["-r"]}" "yes"
    fwktest_assert_string_equals "${map["run_args"]}" "no"
    fwktest_assert_string_equals "${map["run_avail"]}" "yes"

    fwktest_assert_string_equals "${map["create"]}" "no"
    fwktest_assert_string_equals "${map["--create"]}" "no"
    fwktest_assert_string_equals "${map["create_avail"]}" "no"
}

function func_t() {
    echo -n "function [func_t] -t value is ${map["title"]} create value is ${map["create"]} "
}

function func_run() {
    echo -n "function [func_run] -r value is ${map["-r"]}"
}

function test_execution() {
    local -A map
    preparse_args map \
        "name=title     args=yes    short_option=-t     function=func_t" \
        "name=run       args=no     short_option=-r     function=func_run" \
        "name=file      args=opt    short_option=-f     default=default_file" \
        "name=create    args=no"

    parse_args map y --title some_title -r
    fwktest_assert_string_equals \
        "$(exec_args_flow map title run)" \
        "function [func_t] -t value is some_title create value is no function [func_run] -r value is yes"

    fwktest_assert_string_equals \
        "$(exec_args_flow map run title)" \
        "function [func_run] -r value is yesfunction [func_t] -t value is some_title create value is no "
}
