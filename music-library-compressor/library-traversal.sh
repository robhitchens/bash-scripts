# TODO below are rough wants to be implemented
#function compress_file(){}
#function make_target_dir(){}
#function file_compression_stats(){}

scriptName=$(basename "$0")
supportedFormats=("flac" "wav")
supportedOutputFormats=("mp3")

#TODO should add detection to see if compressed file already exists and skip

function enumerate_directory() {
  # TODO below should probably involve some error handling
  echo "Directory: $1"
  leaf=$(basename "$1")
  newDirectory="$targetDirectory/$leaf"
  echo "New Target Directory: $newDirectory"
  # cd-ing into the directory is probably not necessary
  cd "$1"
  for i in ./*; do
    if [[ -f $i ]]; then
      # TODO this logic will eventually need to be broken out into a separate function
      # I don't quite understand how the below line works.
      filename=$(basename -- "$i")
      echo "File: $filename"
      # I don't quite understand how the below line works.
      extension="${filename##*.}"
      echo "File Extension: $extension"

      if [[ $(echo "${supportedFormats[@]}" | grep -o "$extension" | wc -w) -eq 1 ]]; then
        targetFilePath="${newDirectory}/${filename%.*}.mp3"
        echo "File: $filename matches supported formats. Compressing to target: $targetFilePath"
        mkdir -p "$newDirectory"
        ffmpeg -i "$i" -ab 320k -map_metadata 0 -id3v2_version 3 "$targetFilePath"
      else 
        echo "File: $filename does not match supported formats"
      fi
    else
      echo "Item [$i] is not a file and currently being ignored"
    fi
  done
  cd ..
}

//TODO should add way to set debug flag or preview flag
if [ $# -ne 2 ]; then 
  echo "Usage: $scriptName \$sourceDirectory \$targetDirectory" 
  exit 1
fi

echo "Provided directory $1"
echo "Listing subdirectories"
cd $1
# Removing trailing slash
targetDirectory=$(echo "$2" | sed 's:/*$::')
for i in ./*; do
  item=$i
  if [ -d "$item" ]; then 
    enumerate_directory "$item" 
  elif [ -f "$item" ]; then  
    echo "File: $item"
  else
    echo "Unknown Type: [$item] skipping";
  fi
done

