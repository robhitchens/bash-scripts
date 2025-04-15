# Scripts to add

1. zen browser installer
    * download app image
    * make executable
    * move to folder
    *  add desktop entry

# Compressor parallel proposal

Instead of executing ffmpeg per file, would need to calculate new file and create pairs 
of `oldFile:newFile` and run parallel to split input and run an ffmpeg process per pair.
Following that logic would need to be updated to iterate through the new and old file pairs
to get file sizes and calculate file sizes and compression ratios.

Alternatively, could create a function that handles splitting input, compressing and calculating new and old file sizes. Could echo file sizes gather and reduce the values? Maybe that would be better.
