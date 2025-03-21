#!/usr/bin/env bash

# NOTE: Dependencies
# FIXME: below doesn't appear to work in subshells (at least with my limited knowledge)
# alias log='../utils/logger.sh'
# FIXME: aliasing script using function declaration, also assuming similar folder structure on all machines.
function log {(~/projects/bash-scripts/utils/logger.sh "$1" "$2");}

readonly scriptName=$(basename "$0")
readonly supportedFormats=("flac" "wav")
# FIXME: I don't think the below is used
readonly supportedOutputFormats=("mp3")


# Guard clause for inputs
if [[ $# -ne 2 ]]; then
  echo "Usage: $scriptName \$sourceDirectory \$targetDirectory"
  exit 1
fi

log "info" "Provided directory $1"
log "debug" "Listing subdirectories"
log "trace" "changing to directory \"$1\""
cd "$1"

readonly targetDirectory=$(echo "$2" | sed 's:/*$::')
readonly start=`date +%s`
# TODO add logic here

# FIXME: need to figure out way to escape output from subshell separated by newline
# Temporarily setting internal field separator to be new line only
IFS=$'\n'
# Getting fully qualified source file paths.
readonly files=$(ls -R ./ | xargs -I {} realpath --relative-to=/ {})
#IFS=$' \t\n'
for i in $files; do
  # TODO need to trim the beginning of the string to remove reference to home
  #      then prepend the target directory to the file.
  #      Then all I need to check for is whether or not the file type is compatible.
  #      Nevermind I still need to filter out directory strings.
  #      Also, need to filter out other miscellneous strings like values ending with $':'
  log "info" "found /$i"
done
readonly end=`date +%s`
log "info" "Job took $(expr $end - $start) second(s) to run."
