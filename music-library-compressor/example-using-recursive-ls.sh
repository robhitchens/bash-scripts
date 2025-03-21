#!/usr/bin/env bash

# Sample using a single element from ls -R to get fullly qualified path
# to file for compression.

files=$(ls -R /mnt/5D654E2129C52FAB/Music \
  | head -n10 \
  | tail -n9 \
  | xargs -I {} realpath --relative-to=/ {})
IFS=$'\n'
for i in $files; do
echo '$i'
done

