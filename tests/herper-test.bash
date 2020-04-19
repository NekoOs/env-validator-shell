#!/usr/bin/env bash

source ../src/env-validator.bash

NEKOOS_TEST_DONE_COUNTER=0
NEKOOS_TEST_FAIL_COUNTER=0

function test_validate_header() {
    NEKOOS_TEST_DONE_COUNTER=0
    NEKOOS_TEST_FAIL_COUNTER=0
}

function test_validate_footer() {
    print_style "Test $((${NEKOOS_TEST_DONE_COUNTER} + ${NEKOOS_TEST_FAIL_COUNTER})) " blue
    print_style "Success: $NEKOOS_TEST_DONE_COUNTER " success
    print_line_style "Fail: $NEKOOS_TEST_FAIL_COUNTER " danger
}

function print_style () {
    local message=$1
    local style=$2
    local start_color
    local end_color

    case "$style" in
    info)      color="96m" ;;
    blue)      color="34m" ;;
    orange)    color="33m" ;;
    danger)    color="91m" ;;
    success)   color="92m" ;;
    warning)   color="93m" ;;
    *)         color="0m" ;;
    esac

    start_color="\e[$color"
    end_color="\e[0m"

    printf "$start_color%b$end_color" "$message"
}

function print_line_style()
{
    print_style "$1" "$2"
    echo
}


function test_validate()
{
    local code
    local expected=$1
    local closure=$2
    local parameters=${@:3}
    local message
    local mute

    message=$(${closure} ${parameters})

    print_style "test sentence " blue
    print_style "→ " info
    print_style "$closure" orange
    print_line_style "(`sed s/\s/,/g <<< ${parameters}`) "


    if [[ "$message" == "$expected" ]]; then
        code=0
        print_line_style "result: OK" success
        NEKOOS_TEST_DONE_COUNTER=$((${NEKOOS_TEST_DONE_COUNTER}+1))
    else
        code=1
        NEKOOS_TEST_FAIL_COUNTER=$((${NEKOOS_TEST_FAIL_COUNTER}+1))
        print_line_style "result: FAIL" danger
        print_line_style "expect: $expected" danger
        print_line_style "actual: $message" danger
    fi

    return ${code}
}