# Sample using a single element from ls -R to get fullly qualified path
# to file for compression.

ls -R /mnt/5D654E2129C52FAB/Music \
  | head -n2 \
  | tail -n1 \
  | xargs -I {} realpath --relative-to=/ {}
