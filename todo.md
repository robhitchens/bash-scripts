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

# CD MetaData Preparer

- Create script that scrapes discogs searching information utilizing isbn number of cd.
- output in file of format `artist->album->track#->title`? may utilize different format.
- Download cover art and do necessary conversions for embedding in track data.
- Format can then be used to populate metadata for CD tracks when wrapping into flac file.

## Additional distributed pieces

- phone app (or PWA) to scan barcodes and grab upc from barcode
- relay service to take that information and send it to a consumer to pull down the meta data. (this part can be written in go and hosted on some cheap service.)

# Installer script

- source can pull from standard locations and PATH
    - Create script to optionally "install" imported bash scripts into `/usr/local/bin`. Maybe even add auto option for setting execution permissions as well.
    - Should also refactor compression script and other tools to point to `/usr/local/bin`
