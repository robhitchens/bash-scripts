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



#TODO simplify below implementation, can filter out directories early, and can filter out duplicates early?
# PARAMS:
# newDirectory ($1 string) - directory to write compressed file to.
# originalFileName ($2 string) - the original name of the file.
function compressFile {
  # TODO: fill in with extracted implementation of below
}

# PARAMS:
# filename ($1 string) - the name of the file to check based on file extension
# RETURNS:
# 'true' - if file type is supported
# 'false' - if file type is not supported
function isSupportedFormat {
  readonly filename=$(basename -- "$1")
  readonly extension="${filename##*.}"

  # NOTE: could just use return and supply exit code (0,1)
  if [[ $(echo "${supportedFormats[@]}" | grep -o "$extension" | wc -w) -eq 1 ]]; then
    log info "File: $filename matches supported formats."
    echo 'true'
  else
    log warn "File: $filename does not match supported formats."
    echo 'false'
  fi
}

# PARAMS:
# sourcePath ($1 string) - the original fully qualified file path
# targetDir ($2 string) - the target dir to place the file in
function targetName {
  local sourcePath="$1"
  local targetDir="$2"
  #NOTE: can't include logging if trying to use echo to return a value from a function.

  # log info "Compressing target: $targetFilePath"
  # TODO fill out with logic:
  # Remove parent dirs from path, might need to subtract pwd from sourcePath
  # Prepend result with targetDir
  # echo result to return for capture. Might need to print NUL byte terminated string.

  local currentDir=$(pwd)
  log info "Current Dir: $currentDir"
  log debug "Source Path: $sourcePath"
  local targetName=$(echo "$sourcePath" | sed -E -e "s:^$currentDir::g" -e "s:(.*):$targetDir\1:g")
  echo "$targetName"
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
IFS=$'\n'
# NOTE: shouldn't need to override the internal field separator by using NUL terminated IO
# Getting fully qualified source file paths.
#readonly files=$(ls -R ./ | xargs -I {} realpath --relative-to=/ {})
readonly files=$(find ./ -print0 | xargs -0 realpath --relative-to=/)
#| xargs -I {} realpath --relative-to=/ {})
#IFS=$' \t\n'
for fd in $files; do
  if [[ -d "fd" ]]; then
    log warn "Encountered directory [/$fd] skipping" 
  else
    log info "found /$fd"
    supported=$(isSupportedFormat "/$fd" | tail -n1)
    newTargetFilename=$(targetName "/$fd" "$targetDirectory" | tail -n1)

    targetDir=$(dirname $newTargetFilename)
    log trace "Executing: mkdir -p \"$targetDir\""
    mkdir -p "$targetDir"

    # TODO below logic should be migrated to compressFile
    if [[ $supported -eq 'true' ]]; then
      # NOTE: due to log function utilizing echo, need to pipe to tail to get the last line for assignment
      newTargetFilename=$(echo "$newTargetFilename" | sed -E -e 's:(.*)(.flac|.wav):\1.mp3:g')
      log debug "NewTargetFilename: $newTargetFilename"
      if [[ -e "$newTargetFilename" ]]; then
        log warn "Compressed file already exists ($newTargetFilename) skipping."
      else
        log info "File: /$fd matches supported formats. Compressing to target: $newTargetFilename"
        log trace "Executing: ffmpeg -i \"/$fd\" -ab 320k -map_metadata 0 -id3v2_version 3 \"$newTargetFilename\""

        # FIXME: dirty way to handle ffmpeg interactively asking to overwrite file.
        yes | ffmpeg -i "/$fd" -ab 320k -map_metadata 0 -id3v2_version 3 "$newTargetFilename"
      fi
    else
      # TODO: Breakout into function to copy non supported file?
      if [[ -e "$newTargetFilename" ]]; then 
        log warn "File already exists ($newTargetFilename) skipping."
      else
        log info "Not supported file type: /$fd\n copying to dir $newTargetFilename"
        cp "/$fd" "$newTargetFilename"
      fi
    fi
  fi
done
readonly end=`date +%s`
log info "Job took $(expr $end - $start) second(s) to run."
