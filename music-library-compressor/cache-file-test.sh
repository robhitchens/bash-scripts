# TODO:
# get list of existing files 
# determine which files already have been compressed
# diff with cache file
# process 
IFS=$'\n'

readonly files=$(find ~/Music -print0 | xargs -0 realpath --relative-to=/)
#readonly otherFiles=$(find /mnt/5D654E2129C52FAB/Music -print0 | head -n 10 | xargs -0 realpath --relative-to=/)
#echo "$files" > /tmp/.cache/indexsh

readonly diffOut=$(echo "$files" | awk '{ print "/" $0 }'  | diff --changed-group-format='%<' --unchanged-group-format='' - ~/.cache/compressor.index)
#| sed -E s/\>\ \(.*\)/'\1'/g)

echo "$diffOut"

# How do I want this algorithm to work?
# Should index file contain original file names that were already compressed?
#   Would probably be the simplest and avoid the most work.
#   Then probably want order diff as 'diff $tmpFile $cacheFile'
#for fd in $files; do
#  if [[ -d "$fd" ]]: then
#
#  fi
#done

