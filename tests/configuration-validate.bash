#!/usr/bin/env bash

cd $(dirname $0)

source herper-test.bash

expected="The key VAR_REQUIRED_DEFINED_COMMENT is required
The key VAR_REQUIRED_DEFINED_NULL is required
The value '250' from VAR_REQUIRED_DEFINED_MAX_200 is greater than 200"

test_validate "$expected" validate_keys_with_rules_from_file
