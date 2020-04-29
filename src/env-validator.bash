#!/bin/bash

NEKOOS_ENV_FILE='.env'
NEKOOS_ENV_RULES='.env.rules'
NEKOOS_EMPTY=''

read -r -d '' NEKOOS_SPLIT_RULES<<-'EOF'
\w+:"([^"]*)"|\w+:'([^']*)'|[^|]+
EOF

function extract_option_rule() {
  rules=$1
  type=$2

  echo "$rules" | egrep -o "$NEKOOS_SPLIT_RULES" | egrep -o ".*:.*" | while IFS=':' read -r key option; do
      echo "$option" | grep -oP '(?<=")\K([^"]+)(?=")'
  done
}

function is_value_greater_than()
{
    echo $(echo "($1 - $2) > 0" | bc)
}

function extract_value() {
  local key=$1
  local rule
  local response

  rule=$(egrep -o "^$key=.*$" ${NEKOOS_ENV_FILE})
  response=$?

  while IFS='=' read -r key value; do
    echo "$value" | sed 's/^"*//;s/"*$//' | sed "s/^'//;s/'*$//"
  done <<<"$rule"

  return ${response}
}

function validate_key_with_rule_for_max() {
  local code
  local key=$1
  local option=$2
  local value

  validate_key_with_rule_for_numeric ${key}
  code=$?

  if [[ ${code} -ne 0 ]]; then
     return ${code}
  fi

  value=$(extract_value "$key")

  assert=$(is_value_greater_than ${value} ${option})

  if [[ ${code} -eq 0 && ${assert} -eq 1 ]]; then
    printf "The value '%s' from %s is greater than %s" ${value} ${key} ${option}
  fi

  return ${code}
}

function validate_key_with_rule_for_min() {
  local code
  local key=$1
  local option=$2
  local value

  validate_key_with_rule_for_numeric ${key}
  code=$?

  if [[ ${code} -ne 0 ]]; then
     return ${code}
  fi

  value=$(extract_value "$key")

  assert=$(is_value_greater_than ${option} ${value})

  if [[ ${assert} -eq 1 ]]; then
    printf "The value '%s' from %s is less than %s" ${value} ${key} ${option}
  fi

  return ${code}
}

function validate_key_with_rule_for_regexp() {
  local key=$1
  local pattern=$2
  local rule
  local response
  local value

  value=$(extract_value "$key")

  egrep -o "$pattern" <<<"$value" >/dev/null 2>&1
  code=$?

  if [[ ${code} -ne 0 && "$value" != '' ]]; then
    printf "The value '%s' from %s is not matching with pattern %s\n" "$value" "$key" "$pattern"
  fi

  return ${code}
}

function validate_key_with_rule_for_integer() {
  local code
  local key=$1

  content=$(validate_key_with_rule_for_regexp "$key" '^[0-9]+([|])?$')
  code=$?

  if [[ ${code} -ne 0 && "$content" != '' ]]; then
    value=$(extract_value "$key")
    printf "The value '%s' from %s is not integer\n" "$value" "$key"
  fi

  return ${code}
}

function validate_key_with_rule_for_numeric() {
  local code
  local key=$1

  content=$(validate_key_with_rule_for_regexp "$key" '^[0-9]+(\.[0-9]*)?$')
  code=$?

  if [[ ${code} -ne 0 && "$content" != '' ]]; then
    value=$(extract_value "$key")
    printf "The value '%s' from %s is not numeric\n" "$value" "$key"
  fi

  return ${code}
}

function validate_key_with_rule_for_decimal() {
  local code
  local key=$1

  content=$(validate_key_with_rule_for_regexp "$key" "^[0-9]+\.[0-9]+$")
  code=$?

  if [[ ${code} -ne 0 && "$content" != '' ]]; then
    value=$(extract_value "$key")
    printf "The value '%s' from %s is not decimal\n" "$value" "$key"
  fi

  return ${code}
}

function validate_key_with_rule_for_required() {
  local code
  local key=$1

  content=$(validate_key_with_rule_for_regexp "$key" '^.+$')
  code=$?

  if [[ ${code} -ne 0 ]]; then
    printf 'The key %s is required\n' "$key"
  fi

  return ${code}
}

function validate_key_with_rule_for_url() {
  local code
  local key=$1

  content=$(validate_key_with_rule_for_regexp "$key" '^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?|^((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(:[0-9]{1,5})?(\/.*)?$')
  code=$?

  if [[ ${code} -ne 0 ]]; then
    printf 'The key %s is not url\n' "$key"
  fi

  return ${code}
}

function validate_key_with_rule_for_email() {
  local code
  local email_pattern
  local key=$1

  content=$(validate_key_with_rule_for_regexp "$key" '[a-zA-Z0-9.-]+@[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)')
  code=$?

  if [[ ${code} -ne 0 ]]; then
    printf 'The key %s is not email\n' "$key"
  fi

  return ${code}
}

function validate_key_with_rule() {
  local key=$1
  local rule=$2
  local option=$3

  case ${rule} in
  required)
    validate_key_with_rule_for_required "$key"
    code=$?
    ;;
  boolean)
    validate_key_with_rule_for_boolean "$key"
    code=$?
    ;;
  integer)
    validate_key_with_rule_for_integer "$key"
    code=$?
    ;;
  decimal)
    validate_key_with_rule_for_decimal "$key"
    code=$?
    ;;
  numeric)
    validate_key_with_rule_for_numeric "$key"
    code=$?
    ;;
  min)
    validate_key_with_rule_for_min "$key" "$option"
    code=$?
    ;;
  max)
    validate_key_with_rule_for_max "$key" "$option"
    code=$?
    ;;
  url)
    validate_key_with_rule_for_url "$key"
    code=$?
    ;;
  email)
    validate_key_with_rule_for_email "$key"
    code=$?
    ;;
  regexp)
    validate_key_with_rule_for_regexp "$key" "$option"
    code=$?
    ;;
  esac

  return ${code}
}

function validate_keys_with_rules_from_file
{
    local fails=0
    local types=(required integer decimal max regexp url email)

    NEKOOS_ENV_FILE=${1:-'.env'}
    NEKOOS_ENV_RULES=${2:-'.env.rules'}

    for type in "${types[@]}"; do
      file=$(grep -oP "\w.*=.*\b$type\b[^\n]*" "$NEKOOS_ENV_RULES")
      if [[ $? -eq 0 ]]; then
        while IFS='=' read -r key rules; do
        option=$(extract_option_rule "$rules" "$type")
        validate_key_with_rule "$key" "$type" "$option"
        if [[ $? -ne 0 ]]; then
            fails=$((fails+1))
        fi
      done <<< "$file"
      fi
    done
    return ${fails}
}