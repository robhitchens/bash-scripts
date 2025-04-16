#!/usr/bin/env bash
function wait {
  readonly seconds=5
  readonly threadNumber="$1"
  local i=0
  while [[ "$i" -lt seconds ]]; do
    sleep 1s
    echo "threadNumber $threadNumber sleeping $i..." | tee -a /tmp/parallel/processes
    i=$((i + 1))
  done
}

#wait "$1"
export -f wait


# <strike>using parallel like this doesn't seem to work, 
# only the first iteration is executed and captured.</strike>
# Okay so now it seems to work, but I don't know why
#parallel wait ::: {1..16}
#echo "$parallelOutput"

# This should work for splitting up the input for ffmpeg
#parallel --colsep '-' echo {1} {2} ::: A-B C-D

IFS=$'\n'
folders='
/tmp/parallel/garbo 1
/tmp/parallel/garbo 2
/tmp/parallel/garbo 3
/tmp/parallel/garbo 4
/tmp/parallel/garbo 5
/tmp/parallel/garbo 6
/tmp/parallel/garbo 7
/tmp/parallel/garbo 8
/tmp/parallel/garbo 9
/tmp/parallel/garbo 10
/tmp/parallel/garbo 11
/tmp/parallel/garbo 12
/tmp/parallel/garbo 13
/tmp/parallel/garbo 14
/tmp/parallel/garbo 15
/tmp/parallel/garbo 16'
  
parallel --verbose --delimiter='\n' 'echo {#} && mkdir -p {}' ::: $(printf '%s\n' $folders)
