#!/usr/bin/env bash

#FIXME: Can't figure out a way to make variables encapsulated.
# Setting default loggingLevel
declare -g _loggingLevel="INFO"

# NOTE: below use of `declare` is not portable
declare -Ag _logLevels
_logLevels["INFO"]=5
_logLevels["WARN"]=4
_logLevels["ERROR"]=3
_logLevels["DEBUG"]=2
_logLevels["TRACE"]=1

# PARAMS:
# level ($1 string)
function setLogLevel {
  if [[ $# -ne 1 ]]; then
    echo "Parmeters doesn't match length of 1. Expected form 'setLogLevel \$level'" >&2
    exit 1
  fi
  local logLevel="$1"
  if [[ ! -z "$logLevel" ]]; then
    _loggingLevel=$(echo "$logLevel" | tr '[:lower:]' '[:upper:]')
  fi
}

# PARAMS: 
# level ($1 string) - the level of the log message
# message ($2 string) - the message to be logged
function log {
  if [[ $# -ne 2 ]]; then
    echo "Parameters doesn't match length of 2. Expected form 'log \$level \$message'" >&2
    exit 1
  fi
  local level=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  local message="$2"
  local timestamp=$(date +%Y-%d-%mT%H:%M:%S)
  if [[ ${_logLevels[$level]} -ge ${_logLevels[$_loggingLevel]} ]]; then
    echo "$timestamp - $level: $message"
  fi
}

export -f log setLogLevel
