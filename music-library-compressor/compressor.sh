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

# PARAMS:
# newDirectory ($1 string) - directory to write compressed file to.
# originalFileName ($2 string) - the original name of the file.
function compressFile {
  # FIXME: need to review and fix
  log debug "compressFile \$1: $1"
  local newDirectory=$1
  log debug "compressFile \$2: $2"
  local originalFileName=$2
  local filename=$(basename -- "$2")

  log info "File: $filename"
  local extension="${filename##*.}"
  log info "File Extension: $extension"

  if [[ $(echo "${supportedFormats[@]}" | grep -o "$extension" | wc -w) -eq 1 ]]; then
    local targetFilePath="${newDirectory}/${filename%.*}.mp3"
    if [[ -e $targetFilePath ]]; then
      log info "Compressed file already exists ($targetFilePath) skipping."
    else
      log info "File: $filename matches supported formats. Compressing to target: $targetFilePath"

      log trace "Executing: mkdir -p \"$newDirectory\""
      mkdir -p "$newDirectory"

      log trace "Executing: ffmpeg -i \"$i\" -ab 320k -map_metadata 0 -id3v2_version 3 \"$targetFilePath\""
      yes | ffmpeg -i "$i" -ab 320k -map_metadata 0 -id3v2_version 3 "$targetFilePath"
    fi
  else
    log warn "File: $filename does not match supported formats. copying"
    targetFilePath="${newDirectory}/${filename}"
    if [[ -e $targetFilePath ]]; then
      log info "File already exists ($targetFilePath) skipping."
    else
      log info "Copying $originalFileName to $targetFilePath"
      cp "$originalFileName" "$targetFilePath"
    fi
  fi
}


# Guard clause for inputs
if [[ $# -ne 2 ]]; then
  echo "Usage: $scriptName \$sourceDirectory \$targetDirectory"
  exit 1
fi

log info "Provided directory $1"
log debug "Listing subdirectories"
log trace "changing to directory \"$1\""
cd "$1"

readonly targetDirectory=$(echo "$2" | sed 's:/*$::')
readonly start=`date +%s`
# TODO add logic here

# FIXME: need to figure out way to escape output from subshell separated by newline
# Temporarily setting internal field separator to be new line only
# IFS=$'\n'
# NOTE: shouldn't need to override the internal field separator by using NUL terminated IO
# Getting fully qualified source file paths.
#readonly files=$(ls -R ./ | xargs -I {} realpath --relative-to=/ {})
readonly files=$(find ./ -print0 | xargs -0 realpath --relative-to=/)
#| xargs -I {} realpath --relative-to=/ {})
#IFS=$' \t\n'
for i in $files; do
  # TODO need to trim the beginning of the string to remove reference to home
  #      then prepend the target directory to the file.
  #      Then all I need to check for is whether or not the file type is compatible.
  #      Nevermind I still need to filter out directory strings.
  #      Also, need to filter out other miscellneous strings like values ending with $':'
  log info "found /$i"
done
readonly end=`date +%s`
log info "Job took $(expr $end - $start) second(s) to run."
