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
parallel wait ::: {1..16}
#echo "$parallelOutput"
