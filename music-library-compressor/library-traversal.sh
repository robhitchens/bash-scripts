# TODO below are rough wants to be implemented
#function compress_file(){}
#function make_target_dir(){}
#function file_compression_stats(){}

scriptName=$(basename "$0")
supportedFormats=("flac" "wav")
supportedOutputFormats=("mp3")

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
  if [ ${logLevels[$level]} -ge ${logLevels[$loggingLevel]} ]; then
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
  filename=$(basename -- "$2")
  
  log "info" "File: $filename"
  # I don't quite understand how the below line works.
  extension="${filename##*.}"
  log "info" "File Extension: $extension"

  if [ $(echo "${supportedFormats[@]}" | grep -o "$extension" | wc -w) -eq 1 ]; then
    # TODO add check to see if compressed file already exists.
    targetFilePath="${newDirectory}/${filename%.*}.mp3"
    log "info" "File: $filename matches supported formats. Compressing to target: $targetFilePath"
    
    log "trace" "Executing: mkdir -p \"$newDirectory\""
    mkdir -p "$newDirectory"

    log "trace" "Executing: ffmpeg -i \"$i\" -ab 320k -map_metadata 0 -id3v2_version 3 \"$targetFilePath\""
    #FIXME: dirty way to handle ffmep asking if we want to overwrite a file
    yes | ffmpeg -i "$i" -ab 320k -map_metadata 0 -id3v2_version 3 "$targetFilePath"
  else 
    log "warn" "File: $filename does not match supported formats"
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
      compressFile "$newDirectory" "$i"
    else
      log "warn" "Item [$i] is not a file and currently being ignored"
    fi
  done

  log "trace" "changing to parent directory"
  cd ..
}

#TODO should add way to set debug flag or preview flag
if [ $# -ne 2 ]; then 
  echo "Usage: $scriptName \$sourceDirectory \$targetDirectory" 
  exit 1
fi

log "info" "Provided directory $1"
log "debug" "Listing subdirectories"
log "trace" "changing to directory \"$1\""
cd $1

# Removing trailing slash
targetDirectory=$(echo "$2" | sed 's:/*$::')
for i in ./*; do
  item=$i
  if [ -d "$item" ]; then 
    enumerate_directory "$item" 
  elif [ -f "$item" ]; then  
    log "info" "File: $item"
    # TODO need to run compressFile here.
  else
    log "warn" "Unknown Type: [$item] skipping"
  fi
done

