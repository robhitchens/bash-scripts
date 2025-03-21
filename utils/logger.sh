#!/usr/bin/env bash

scriptName=$(basename "$0")

# Note below use of `declare` is not portable
declare -A logLevels
logLevels["INFO"]=5
logLevels["WARN"]=4
logLevels["ERROR"]=3
logLevels["DEBUG"]=2
logLevels["TRACE"]=1

# TODO want to pull logLevel from ENV default to INFO if not present
loggingLevel="INFO"

# PARAMS: 
# level ($1 string) - the level of the log message
# message ($2 string) - the message to be logged
function log(){
  level=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  message="$2"
  timestamp=$(date +%Y-%d-%mT%H:%M:%S)
  if [[ ${logLevels[$level]} -ge ${logLevels[$loggingLevel]} ]]; then
    echo "$timestamp - $level: $message"
  #else
  #  echo "level string value: $level"
  #  echo "provided level value: ${logLevels[$level]}"
  #  echo "configured level value: ${logLevels[$loggingLevel]}"
  fi
}

# TODO should add support for a help flag

if [[ $# -ne 2 ]]; then
  echo "Usage: $scriptName \$logLevel \$message"
  exit 1
fi

log "$1" "$2"
