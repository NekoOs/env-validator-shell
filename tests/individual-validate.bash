#!/usr/bin/env bash

cd $(dirname $0)

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

# TESTING FOR  VALIDATION OF REQUIRED

test_validate 'The key VAR_REQUIRED_UNDEFINED is required'       validate_key_with_rule_for_required VAR_REQUIRED_UNDEFINED
test_validate 'The key VAR_REQUIRED_DEFINED_COMMENT is required' validate_key_with_rule_for_required VAR_REQUIRED_DEFINED_COMMENT
test_validate 'The key VAR_REQUIRED_DEFINED_NULL is required'    validate_key_with_rule_for_required VAR_REQUIRED_DEFINED_NULL
test_validate "$NEKOOS_EMPTY"                                    validate_key_with_rule_for_required VAR_REQUIRED_DEFINED_STRING
test_validate "$NEKOOS_EMPTY"                                    validate_key_with_rule_for_required VAR_REQUIRED_DEFINED_INTEGER
test_validate "$NEKOOS_EMPTY"                                    validate_key_with_rule_for_required VAR_REQUIRED_DEFINED_DECIMAL
test_validate "$NEKOOS_EMPTY"                                    validate_key_with_rule_for_required VAR_REQUIRED_DEFINED_MAX_200
test_validate "$NEKOOS_EMPTY"                                    validate_key_with_rule_for_required VAR_REQUIRED_DEFINED_MIN_200
test_validate "$NEKOOS_EMPTY"                                    validate_key_with_rule_for_required VAR_REQUIRED_DEFINED_PATTERN_EMAIL

# TESTING FOR  VALIDATION OF INTEGER

test_validate "The value 'lorem ipsum' from VAR_REQUIRED_DEFINED_STRING is not integer"                     validate_key_with_rule_for_integer VAR_REQUIRED_DEFINED_STRING
test_validate "$NEKOOS_EMPTY"                                                                                 validate_key_with_rule_for_integer VAR_REQUIRED_DEFINED_INTEGER
test_validate "The value '31.64' from VAR_REQUIRED_DEFINED_DECIMAL is not integer"                            validate_key_with_rule_for_integer VAR_REQUIRED_DEFINED_DECIMAL
test_validate "$NEKOOS_EMPTY"                                                                                 validate_key_with_rule_for_integer VAR_REQUIRED_DEFINED_MAX_200
test_validate "$NEKOOS_EMPTY"                                                                                 validate_key_with_rule_for_integer VAR_REQUIRED_DEFINED_MIN_200
test_validate "The value 'neder.fandino@outlook.com' from VAR_REQUIRED_DEFINED_PATTERN_EMAIL is not integer"  validate_key_with_rule_for_integer VAR_REQUIRED_DEFINED_PATTERN_EMAIL

# TESTING FOR  VALIDATION OF DECIMAL

test_validate "The value 'lorem ipsum' from VAR_REQUIRED_DEFINED_STRING is not decimal"                     validate_key_with_rule_for_decimal VAR_REQUIRED_DEFINED_STRING
test_validate "The value '32' from VAR_REQUIRED_DEFINED_INTEGER is not decimal"                               validate_key_with_rule_for_decimal VAR_REQUIRED_DEFINED_INTEGER
test_validate "$NEKOOS_EMPTY"                                                                                 validate_key_with_rule_for_decimal VAR_REQUIRED_DEFINED_DECIMAL
test_validate "The value '250' from VAR_REQUIRED_DEFINED_MAX_200 is not decimal"                              validate_key_with_rule_for_decimal VAR_REQUIRED_DEFINED_MAX_200
test_validate "The value '150' from VAR_REQUIRED_DEFINED_MIN_200 is not decimal"                              validate_key_with_rule_for_decimal VAR_REQUIRED_DEFINED_MIN_200
test_validate "The value 'neder.fandino@outlook.com' from VAR_REQUIRED_DEFINED_PATTERN_EMAIL is not decimal"  validate_key_with_rule_for_decimal VAR_REQUIRED_DEFINED_PATTERN_EMAIL

# TESTING FOR  VALIDATION OF MAX

test_validate "The value 'lorem ipsum' from VAR_REQUIRED_DEFINED_STRING is not numeric"                      validate_key_with_rule_for_max VAR_REQUIRED_DEFINED_STRING        200
test_validate "$NEKOOS_EMPTY"                                                                                 validate_key_with_rule_for_max VAR_REQUIRED_DEFINED_INTEGER       200
test_validate "$NEKOOS_EMPTY"                                                                                 validate_key_with_rule_for_max VAR_REQUIRED_DEFINED_DECIMAL       200
test_validate "The value '250' from VAR_REQUIRED_DEFINED_MAX_200 is greater than 200"                           validate_key_with_rule_for_max VAR_REQUIRED_DEFINED_MAX_200       200
test_validate "$NEKOOS_EMPTY"                                                                                 validate_key_with_rule_for_max VAR_REQUIRED_DEFINED_MIN_200       200
test_validate "The value 'neder.fandino@outlook.com' from VAR_REQUIRED_DEFINED_PATTERN_EMAIL is not numeric"  validate_key_with_rule_for_max VAR_REQUIRED_DEFINED_PATTERN_EMAIL 200

# TESTING FOR  VALIDATION OF MIN

test_validate "The value 'lorem ipsum' from VAR_REQUIRED_DEFINED_STRING is not numeric"                       validate_key_with_rule_for_min VAR_REQUIRED_DEFINED_STRING        200
test_validate "The value '32' from VAR_REQUIRED_DEFINED_INTEGER is less than 200"                             validate_key_with_rule_for_min VAR_REQUIRED_DEFINED_INTEGER       200
test_validate "The value '31.64' from VAR_REQUIRED_DEFINED_DECIMAL is less than 200"                          validate_key_with_rule_for_min VAR_REQUIRED_DEFINED_DECIMAL       200
test_validate "$NEKOOS_EMPTY"                                                                                 validate_key_with_rule_for_min VAR_REQUIRED_DEFINED_MAX_200       200
test_validate "The value '150' from VAR_REQUIRED_DEFINED_MIN_200 is less than 200"                            validate_key_with_rule_for_min VAR_REQUIRED_DEFINED_MIN_200       200
test_validate "The value 'neder.fandino@outlook.com' from VAR_REQUIRED_DEFINED_PATTERN_EMAIL is not numeric"  validate_key_with_rule_for_min VAR_REQUIRED_DEFINED_PATTERN_EMAIL 200

## TESTING FOR  VALIDATION OF REGEXP

test_validate "The value 'lorem ipsum' from VAR_REQUIRED_DEFINED_STRING is not matching with pattern [a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}" validate_key_with_rule_for_regexp VAR_REQUIRED_DEFINED_STRING "[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"
test_validate "The value '32' from VAR_REQUIRED_DEFINED_INTEGER is not matching with pattern [a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"         validate_key_with_rule_for_regexp VAR_REQUIRED_DEFINED_INTEGER "[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"
test_validate "The value '31.64' from VAR_REQUIRED_DEFINED_DECIMAL is not matching with pattern [a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"      validate_key_with_rule_for_regexp VAR_REQUIRED_DEFINED_DECIMAL "[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"
test_validate "The value '250' from VAR_REQUIRED_DEFINED_MAX_200 is not matching with pattern [a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"        validate_key_with_rule_for_regexp VAR_REQUIRED_DEFINED_MAX_200 "[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"
test_validate "The value '150' from VAR_REQUIRED_DEFINED_MIN_200 is not matching with pattern [a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"        validate_key_with_rule_for_regexp VAR_REQUIRED_DEFINED_MIN_200 "[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"
test_validate "$NEKOOS_EMPTY"                                                                                                                validate_key_with_rule_for_regexp VAR_REQUIRED_DEFINED_PATTERN_EMAIL "[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}"

test_validate_footer