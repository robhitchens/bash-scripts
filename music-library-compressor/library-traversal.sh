# TODO below are rough wants to be implemented
function compress_file(){}
function make_target_dir(){}
function file_compression_stats(){}

function enumerate_directory() {
  # TODO below should probably involve some error handling
    echo "Directory: $1"
    cd "$1"
    for i in ./*; do
      if [[ -f $i ]]; then
        echo "File: $i"
      fi
    done
    cd ..
}

echo "Provided directory $1"
echo "Listing subdirectories"
cd $1
for i in ./*; do
  item=$i
  if [ -d "$item" ] 
  then enumerate_directory "$item";
  elif [ -f "$item" ] 
  then  echo "File: item";
  else
    echo "Unknown Type: [$item] skipping";
  fi
done


