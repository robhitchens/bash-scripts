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

#TODO this should be broken out in separate functions.
# PARAMS:
# newTargetFilename ($1 string) - Fully qualified path to write compressed file to.
function compressFile {
  newTargetFilename="$1"
  log debug "NewTargetFilename: $newTargetFilename"
  log info "File: /$fd matches supported formats. Compressing to target: $newTargetFilename"
  log trace "Executing: ffmpeg -i \"/$fd\" -ab 320k -map_metadata 0 -id3v2_version 3 \"$newTargetFilename\""

  # FIXME: dirty way to handle ffmpeg interactively asking to overwrite file.
  yes | ffmpeg -i "/$fd" -ab 320k -map_metadata 0 -id3v2_version 3 "$newTargetFilename"
}

# PARAMS: 
# filename ($1 string) - Fully qualified path to compressed file
# RETURNS:
# Boolean (string) - 'true' or 'false' as to whether or not file already exists.
function compressedFileExists {
  filename="$1"
  if [[ -e "$filename" ]]; then
    # "return"
    echo 'true'
  else
    # "return"
    echo 'false'
  fi
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
    # "return"
    echo 'true'
  else
    log warn "File: $filename does not match supported formats."
    # "return"
    echo 'false'
  fi
}

# PARAMS:
# sourcePath ($1 string) - the original fully qualified file path
# targetDir ($2 string) - the target dir to place the file in
# currentDir (implicit, string) - current directory of execution provided by pwd
# RETURNS:
# targetName (string) - generated target filename
function targetName {
  local sourcePath="$1"
  local targetDir="$2"
  local currentDir=$(pwd)

  log info "Current Dir: $currentDir"
  log debug "Source Path: $sourcePath"

  local targetName=$(echo "$sourcePath" | sed -E -e "s:^$currentDir::g" -e "s:(.*):$targetDir\1:g")

  # "return"
  echo "$targetName"
}

# PARAMS:
# sourceFile ($1 string) - original file to copy
# targetFile ($2 string) - target file name to copy to
function copyUnsupportedFile {
  local sourceFile="$1"
  local targetFile="$2"
  if [[ -e "$targetFile" ]]; then 
    log warn "File already exists ($targetFile) skipping."
  else
    log info "Not supported file type: $sourceFile\n copying to dir $targetFile"
    cp "$sourceFile" "$targetFile"
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

# FIXME: need to figure out way to escape output from subshell separated by newline
# Temporarily setting internal field separator to be new line only
IFS=$'\n'

# NOTE: shouldn't need to override the internal field separator by using NUL terminated IO
# Getting fully qualified source file paths.
readonly files=$(find ./ -print0 | xargs -0 realpath --relative-to=/)

totalOrgFSizeMB="0"
totalNewFSizeMB="0"
# TODO: this loop is starting to grow and could probably be refactored into a couple small functions
for fd in $files; do
  if [[ -d "fd" ]]; then
    log warn "Encountered directory [/$fd] skipping" 
  else
    log info "found /$fd"

    # NOTE: due to log function utilizing echo, need to pipe to tail to get the last line for assignment
    supported=$(isSupportedFormat "/$fd" | tail -n1)
    newTargetFilename=$(targetName "/$fd" "$targetDirectory" | tail -n1)

    targetDir=$(dirname $newTargetFilename)
    log trace "Executing: mkdir -p \"$targetDir\""
    mkdir -p "$targetDir"
    
    if [[ $supported = 'true' ]]; then
      mp3Filename=$(echo "$newTargetFilename" | sed -E -e 's:(.*)(.flac|.wav):\1.mp3:g')
      fileExists=$(compressedFileExists "$mp3Filename" | tail -n1)
      if [[ $fileExists = 'true' ]]; then
        log warn "Compressed file already exists ($newTargetFilename) skipping."
      else
        compressFile "$mp3Filename"
        originalFileSizeInBytes=$(stat -c %s "/$fd")
        newFileSizeInBytes=$(stat -c %s "$mp3Filename")

        orgFSizeMB=$(echo "$originalFileSizeInBytes/1024/1024" | bc)
        newFSizeMB=$(echo "$newFileSizeInBytes/1024/1024" | bc)
        log debug "File size in bytes before [$orgFSizeMB]MB after [$newFSizeMB]MB"

        compressionRatio=$(echo "scale=4; $newFileSizeInBytes/$originalFileSizeInBytes" | bc)
        log debug "Compression factor: $compressionRatio"

        totalOrgFSizeMB=$(echo "$totalOrgFSizeMB+$orgFSizeMB" | bc)
        totalNewFSizeMB=$(echo "$totalNewFSizeMB+$newFSizeMB" | bc)
      fi
    else
      copyUnsupportedFile "/$fd" "$newTargetFilename"
    fi
  fi
done
readonly end=`date +%s`
log info "Job took $(expr $end - $start) second(s) to run."
totalCompressionRatio=$(echo "scale=2; ($totalNewFSizeMB/$totalOrgFSizeMB)*100" | bc)
log info "Total original file size: $totalOrgFSizeMB (MB)"
log info "Total new file size: $totalNewFSizeMB (MB)"
log info "Total compression ratio: $totalCompressionRatio%"
