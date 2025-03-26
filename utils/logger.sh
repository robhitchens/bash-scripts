#!/usr/bin/env bash

readonly scriptName=$(basename "$0")
# NOTE: below use of `declare` is not portable
declare -A logLevels
logLevels["INFO"]=5
logLevels["WARN"]=4
logLevels["ERROR"]=3
logLevels["DEBUG"]=2
logLevels["TRACE"]=1


# FIXME should add guard to make sure logLevel is valid value.
if [[ ! -z "$logLevel" ]]; then
  loggingLevel=$(echo "$logLevel" | tr '[:lower:]' '[:upper:]')
else
  loggingLevel="INFO"
fi

# PARAMS: 
# level ($1 string) - the level of the log message
# message ($2 string) - the message to be logged
function log(){
  local level=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  local message="$2"
  local timestamp=$(date +%Y-%d-%mT%H:%M:%S)
  if [[ ${logLevels[$level]} -ge ${logLevels[$loggingLevel]} ]]; then
    echo "$timestamp - $level: $message"
  fi
}

# TODO should add support for a help flag

if [[ $# -ne 2 ]]; then
  echo "Usage: $scriptName \$logLevel \$message"
  exit 1
fi

log "$1" "$2"
