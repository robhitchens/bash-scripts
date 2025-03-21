#!/usr/bin/env bash

# TODO below are rough wants to be implemented
#function compress_file(){}
#function make_target_dir(){}
#function file_compression_stats(){}
#function duration

# NOTE can use `stat -c %s filename` to get filesize in bytes.
# NOTE can use `echo "scale=2; $endSize/$startSize" | bc` to calculate floating point values
#
# NOTE Need to figure out how strictly I want to track the before and after compression size
#      Do I want to total everything and then do the percentage at the end? or keep a rolling
#      tally of the compression size. I would probably want a total beginning size and ending size.
#      Anyways, looks like I have to do a bit more thinking about this, but I'm almost finished with
#      writing for my usecase and then some tidying up.
#      Also, should add at least a counter for total files, and files compressed during run.

scriptName=$(basename "$0")
supportedFormats=("flac" "wav")
supportedOutputFormats=("mp3")

# Note below use of `declare` is not portable
declare -A logLevels
logLevels["INFO"]=5
logLevels["WARN"]=4
logLevels["ERROR"]=3
logLevels["DEBUG"]=2
logLevels["TRACE"]=1

loggingLevel=INFO

function log(){
  #TODO should add default for level if not provided, but I'm the only one using so... eh.
  level=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  expression=$2
  timestamp=$(date +%Y-%d-%mT%H:%M:%S)
  #TODO needs work to apply precedence to levels.
  if [[ ${logLevels[$level]} -ge ${logLevels[$loggingLevel]} ]]; then
    echo "$timestamp - $level: $expression"
  fi
}

#TODO should add detection to see if compressed file already exists and skip
#TODO should capture stats. Although not sure that doing math in bash is a great idea.
#TODO should add support for recursion through directories, but not necessary currently.

function compressFile() {
  log "debug" "compressFile \$1: $1"
  newDirectory=$1
  # I don't quite understand how the below line works.
  log "debug" "compressFile \$2: $2"
  originalFileName=$2
  filename=$(basename -- "$2")
  
  log "info" "File: $filename"
  # I don't quite understand how the below line works.
  extension="${filename##*.}"
  log "info" "File Extension: $extension"

  if [[ $(echo "${supportedFormats[@]}" | grep -o "$extension" | wc -w) -eq 1 ]]; then
    targetFilePath="${newDirectory}/${filename%.*}.mp3"
    if [[ -e $targetFilePath ]]; then
      log "info" "Compressed file already exists ($targetFilePath) skipping."
    else 
      log "info" "File: $filename matches supported formats. Compressing to target: $targetFilePath"
      
      log "trace" "Executing: mkdir -p \"$newDirectory\""
      mkdir -p "$newDirectory"

      log "trace" "Executing: ffmpeg -i \"$i\" -ab 320k -map_metadata 0 -id3v2_version 3 \"$targetFilePath\""
      #FIXME: dirty way to handle ffmep asking if we want to overwrite a file
      yes | ffmpeg -i "$i" -ab 320k -map_metadata 0 -id3v2_version 3 "$targetFilePath"
    fi
  else 
    log "warn" "File: $filename does not match supported formats, copying"
    targetFilePath="${newDirectory}/${filename}"
    if [[ -e $targetFilePath ]]; then
      log "info" "File already exists ($targetFilePath) skipping."
    else 
      log "info" "Copying $originalFileName to $targetFilePath"
      cp "$originalFileName" "$targetFilePath"
    fi
  fi
}

function enumerate_directory() {
  # TODO below should probably involve some error handling
  log "info" "Directory: $1"

  leaf=$(basename "$1")
  newDirectory="$targetDirectory/$leaf"
  log "info" "New Target Directory: $newDirectory"

  # cd-ing into the directory is probably not necessary
  log "trace" "changing to directory \"$1\""
  cd "$1"

  for i in ./*; do
    if [[ -f $i ]]; then
      log "trace" "executing compressFile \"$newDirectory\" \"$i\""
      # TODO should probably put check here if file needs to be sent to compression function here.
      # if not then can copy file over
      # Also should check if file already exists before bothering to compress, but that can be done in the compression function.
      compressFile "$newDirectory" "$i"
    else
      log "warn" "Item [$i] is not a file and currently being ignored"
    fi
  done

  log "trace" "changing to parent directory"
  cd ..
}

#TODO should add way to set debug flag or preview flag
if [[ $# -ne 2 ]]; then 
  echo "Usage: $scriptName \$sourceDirectory \$targetDirectory" 
  exit 1
fi

log "info" "Provided directory $1"
log "debug" "Listing subdirectories"
log "trace" "changing to directory \"$1\""
cd "$1"

# Removing trailing slash
readonly targetDirectory=$(echo "$2" | sed 's:/*$::')
readonly start=`date +%s`
for i in ./*; do
  item=$i
  if [[ -d "$item" ]]; then 
    enumerate_directory "$item" 
  elif [[ -f "$item" ]]; then  
    log "info" "File: $item"
    compressFile "$targetDirectory" "$item"
  else
    log "warn" "Unknown Type: [$item] skipping"
  fi
done
readonly end=`date +%s`
log "info" "Job took $(expr $end - $start) second(s) to run."
