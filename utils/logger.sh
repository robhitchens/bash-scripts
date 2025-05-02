#!/usr/bin/env bash

# TODO: should expose a function that starts a background process that reads from a fifo file.
#       Process would be an infinite loop that read from fifo and writes to a file until killed?

# FIXME: Can't figure out a way to make variables encapsulated.
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

declare -g _logFileLocation
function setLogLocation {
  if [[ $# -ne 1 ]]; then
    echo "Parameters doesn't match length of 1. Expected form 'setLogLocation \$location'" >&2
# TODO: below doesn't quite work if file doesn't already exist
#  elif [[ ! -f "$1" ]]; then
#    echo "file [$1] is not a valid file" >&2
  fi
  _logFileLocation="$1"

  if [[ ! -e "$_logFileLocation" ]]; then
    mkdir -p "$(dirname "$_logFileLocation")"
    touch "$_logFileLocation"
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
  local timestamp=$(date +%Y-%m-%dT%H:%M:%S)
  if [[ ${_logLevels[$level]} -ge ${_logLevels[$_loggingLevel]} ]]; then
    if [[ -n "$_logFileLocation" ]]; then
      echo "$timestamp - $level: $message" >> "$_logFileLocation"
    else
      echo "$timestamp - $level: $message" >&1
    fi
  fi
}

export -f log setLogLevel setLogLocation
