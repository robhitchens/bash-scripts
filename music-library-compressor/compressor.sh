#!/usr/bin/env bash

# BUG: issue cropping up where some entries in compressor.log is still getting through diff.
# TODO: Add the following options:
#     --dry-run -> run and output actions, but don't perform them
#     --no-cache -> run but ignore cache file.
#     --source-dir
#     --target-dir

if [[ "$1" == '--help' ]]; then
	cat <<EOF
Usage:
  ./compressor.sh source_dir dest_dir
  
  Due to the multi-threaded nature consider tailing the log file using the below
  ./compressor.sh source_dir dest_dir & tail -F /tmp/compressor/logFile.log
EOF
	exit 0
fi
# NOTE: Dependencies

source ~/projects/bash-scripts/utils/logger.sh
setLogLevel info
setLogLocation /tmp/compressor/logFile.log

readonly scriptName=$(basename "$0")
readonly supportedFormats=("flac" "wav")
# FIXME: I don't think the below is used
readonly supportedOutputFormats=("mp3")

# PARAMS:
# fileName ($1 string) - fileName for tempFile
# RETURNS:
# path (string) - path to the created tmp file
function makeTmpFile {
	local fileName="$1"
	local directory="/tmp/compressor"
	local tempFile="$directory/$fileName"

	if [[ ! -e "$tempFile" ]]; then
		log debug "making temp file: $tempFile"
		mkdir -p "$directory"
		touch "$tempFile"
	else
		log debug "clearing temp file: $tempFile"
		>$tempFile
	fi

	echo "$tempFile"
}

readonly indexFileLocation=~/.cache/compressor.log
if [[ ! -e "$indexFileLocation" ]]; then
	log debug "cache file [$indexFileLocation] doesn't exist, creating"
	touch "$indexFileLocation"
else
	log info "sorting cache file entries"
	# TODO not sure if this will workout like I expect it to
	readonly temp=$(makeTmpFile "cache-sorted")
	cat "$indexFileLocation" | sort -h - >"$temp"
	mv "$temp" "$indexFileLocation"
fi
export indexFileLocation

# PARAMS:
# fileName ($1 string) - fileName to add to cache
function addFileToCache {
	local fileName="$1"
	# BUG: for some reason more often than not, $filename will be blank, but the value will still be added to the cache. Maybe it's a scoping issue?
	log debug "adding filename [$filename] to cache"
	echo "$fileName" >>"$indexFileLocation"
}

# PARAMS:
# sourceFile ($1 string) - Fully qualified path to source file.
# newTargetFilename ($2 string) - Fully qualified path to write compressed file to.
function compressFile {
	local sourceFile="$1"
	local newTargetFilename="$2"
	log debug "NewTargetFilename: $newTargetFilename"
	log info "File: $sourceFile matches supported formats. Compressing to target: $newTargetFilename"
	log trace "Executing: ffmpeg -i \"$sourceFile\" -ab 320k -map_metadata 0 -id3v2_version 3 \"$newTargetFilename\""

	# FIXME: capture output and use logger to print?
	# FIXME: dirty way to handle ffmpeg interactively asking to overwrite file.
	# FIXME: the preceding slash shouldn't be required.
	yes | ffmpeg -i "$sourceFile" -ab 320k -map_metadata 0 -id3v2_version 3 "$newTargetFilename"
}

# PARAMS:
# filename ($1 string) - Fully qualified path to compressed file
# RETURNS:
# (string) - 'exists' if the file exists or '' if the file does not exist
function compressedFileExists {
	local filename="$1"
	if [[ -e "$filename" ]]; then
		# "return"
		echo 'exists'
	else
		# "return"
		echo ''
	fi
}

# PARAMS:
# thread ($1 int) - the thread number currently being executed
# sourceFile ($2 string) - source file name
# targetFile ($3 string) - target file name
function compressFileExt {
	local thread="$1"
	local sourceFile="$2"
	local mp3Filename="$3"

	log info "Thread[$thread] compressing source[$sourceFile] to target[$mp3Filename]"
	fileExists=$(compressedFileExists "$mp3Filename" | tail -n1)

	if [[ -n "$fileExists" ]]; then
		log warn "Thread[$thread] Compressed file already exists ($mp3Filename) skipping."
		log debug "adding file [$sourceFile] to cache"
		echo "$sourceFile" >>"$indexFileLocation"
	else
		compressFile "$sourceFile" "$mp3Filename"
		log debug "adding file [$sourceFile] to cache"
		echo "$sourceFile" >>"$indexFileLocation"
	fi
}

# PARAMS:
# filename ($1 string) - the name of the file to check based on file extension
# RETURNS:
# (string) - 'supported' if file type is supported and '' if the file is not supported.
function isSupportedFormat {
	local filename=$(basename -- "$1")
	local extension="${filename##*.}"

	# NOTE: could just use return and supply exit code (0,1)
	if [[ $(echo "${supportedFormats[@]}" | grep -o "$extension" | wc -w) -eq 1 ]]; then
		log info "File: $filename matches supported formats."
		# "return"
		echo 'supported'
	else
		log warn "File: $filename does not match supported formats."
		# "return"
		echo ''
	fi
}

# PARAMS:
# sourcePath ($1 string) - the original fully qualified file path
# targetDir ($2 string) - the target dir to place the file in
# currentDir (implicit, string) - current directory of execution provided by pwd
# RETURNS:
# targetName (string) - generated target filename
function targetName {
	local sourcePath="$1"
	local targetDir="$2"
	local currentDir=$(pwd)

	log trace "Current Dir: $currentDir"
	log trace "Source Path: $sourcePath"

	local tName=$(echo "$sourcePath" | sed -E -e "s:^$currentDir::g" -e "s:(.*):$targetDir\1:g")

	log debug "generated target name[$tName]"

	# "return"
	echo "$tName"
}

# PARAMS:
# sourceFile ($1 string) - original file to copy
# targetFile ($2 string) - target file name to copy to
function copyUnsupportedFile {
	local sourceFile="$1"
	local targetFile="$2"
	if [[ -e "$targetFile" ]]; then
		log warn "File already exists ($targetFile) skipping."
	else
		log info "Not supported file type: $sourceFile\n copying to dir $targetFile"
		cp "$sourceFile" "$targetFile"
	fi
}

# TODO might just update to take in file of folders and target directory?
# PARAMS:
# files ($@ string list) - list of files to process.
# RETURNS:
# supportedFilesPath (string path) - path to file of supported files
function filterSupportedAndUnsupported {
	local inputFiles="$@"
	local supportedFile=$(makeTmpFile "supported" | tail -n1)
	local unsupportedFile=$(makeTmpFile "unsupported" | tail -n1)
	for file in $inputFiles; do
		local newTargetFileName=$(targetName "$file" "$targetDirectory" | tail -n1)
		if [[ -d "$file" ]]; then
			if [[ $(cat "$indexFileLocation" | grep -o "$file" | wc -w) -eq 1 ]]; then
				log debug "Directory [$file] already exists in cache, skipping."
			else
				addFileToCache "$file"
			fi
		else
			# NOTE: due to log function utilizing echo, need to pipe to tail to get the last line for assignment
			supported=$(isSupportedFormat "$file" | tail -n1)
			if [[ -n $supported ]]; then
				echo "$file" >>"$supportedFile"
			else
				echo "$file" >>"$unsupportedFile"
				addFileToCache "$file"
			fi
		fi
	done
	echo "$supportedFile::$unsupportedFile"
}

# PARAMS:
# file ($1 string file) - file with input to process
# RETURNS:
# processedFilePath (string path) - path to file containing the processed output.
function generateTargetNames {
	local file="$1"
	local outputFile=$(makeTmpFile "$(basename "$file")-processed" | tail -n1)

	log debug "generating targetNames in [$outputFile]"

	for item in $(cat "$file"); do
		local target=$(targetName "$item" "$targetDirectory" | tail -n1)
		echo "$item::$target" >>"$outputFile"
	done

	echo "$outputFile"
}

function generateCompressedNames {
	local file="$1"
	local outputFile=$(makeTmpFile "$(basename "$file")-compressed" | tail -n1)

	log debug "generating compressed file names in [$outputFile]"
	for item in $(cat "$file"); do
		local split=(${item//::/$'\n'})
		local mp3Filename=$(echo "${split[1]}" | sed -E -e 's:(.*)(.flac|.wav):\1.mp3:g')
		log debug "generated mp3Filename [$mp3Filename]"
		echo "${split[0]}::$mp3Filename" >>"$outputFile"
	done

	echo "$outputFile"
}

function makeTargetDirs {
	local inputFile="$1"
	for item in $(cat "$inputFile"); do
		log debug "processing $item for target dir"
		local split=(${item//::/$'\n'})
		local target="${split[1]}"
		local targetDir=$(dirname "$target")
		log debug "making target dir [$targetDir]"
		mkdir -p "$targetDir"
	done
}

# PARAMS:
# file ($1 string file) - file containing delimited input
function printStatistics {
	local compressedFilesList="$1"
	local totalOrgFSizeMB="0"
	local totalNewFSizeMB="0"
	local numberOfFilesProcessed=$(cat "$compressedFilesList" | wc -l)
	readonly end=$(date +%s)

	log debug "calculating stats"
	for item in $(cat "$compressedFilesList"); do
		#TODO not sure if this is going to work.
		local split=(${item//::/$'\n'})
		local orgFSizeMB=$(stat -c %s "${split[0]}")
		# FIXME below checks for errors is bugged.
		#if [[ -n $? ]]; then
		#  orgFSizeMB="0"
		#fi
		local newFSizeMB=$(stat -c %s "${split[1]}")
		#if [[ -n $? ]]; then
		#  newFSizeMB="0"
		#fi
		orgFSizeMB=$(echo "$orgFSizeMB/1024/1024" | bc)
		newFSizeMB=$(echo "$newFSizeMB/1024/1024" | bc)
		totalOrgFSizeMB=$(echo "$totalOrgFSizeMB+$orgFSizeMB" | bc)
		totalNewFSizeMB=$(echo "$totalNewFSizeMB+$newFSizeMB" | bc)
	done

	log info "Job took $(expr $end - $start) second(s) to run on $numberOfFilesProcessed files."
	if [[ "$totalOrgFSizeMB" -eq '0' ]]; then
		totalCompressionRatio="0.00"
	else
		totalCompressionRatio=$(echo "scale=2; ($totalNewFSizeMB/$totalOrgFSizeMB)*100" | bc)
	fi
	log info "Total original file size: $totalOrgFSizeMB (MiB)"
	log info "Total new file size: $totalNewFSizeMB (MiB)"
	log info "Total compression ratio: $totalCompressionRatio%"
}

# TODO: should probably wrap some of below into functions for readability

# Guard clause for inputs
if [[ $# -ne 2 ]]; then
	echo "Usage: $scriptName \$sourceDirectory \$targetDirectory"
	exit 1
fi

log info "Provided directory $1"
log trace "changing to directory \"$1\""
cd "$1"

readonly targetDirectory=$(echo "$2" | sed 's:/*$::')
readonly start=$(date +%s)

# FIXME: need to figure out way to escape output from subshell separated by newline
# Temporarily setting internal field separator to be new line only
IFS=$'\n'
# NOTE: shouldn't need to override the internal field separator by using NUL terminated IO

# Getting fully qualified source file paths.
log debug "Listing subdirectories"
readonly files=$(find ./ -print0 | sort -z -h - | xargs -0 realpath --relative-to=/)

log debug "diffing with cache file"
readonly indexDiff=$(echo "$files" | awk '{ print "/" $0 }' | diff --changed-group-format='%<' --unchanged-group-format='' - "$indexFileLocation")

log debug "filtering files"
readonly filteredFiles=$(filterSupportedAndUnsupported "$indexDiff" | tail -n1)
readonly splitFiltered=(${filteredFiles//::/$'\n'})

log debug "generating names"
readonly supportedFiles=$(generateTargetNames "${splitFiltered[0]}" | tail -n1)
readonly unsupportedFiles=$(generateTargetNames "${splitFiltered[1]}" | tail -n1)
readonly mp3Files=$(generateCompressedNames "$supportedFiles" | tail -n1)

log debug "making target dirs"
makeTargetDirs "$mp3Files"
makeTargetDirs "$unsupportedFiles"

log debug "copying unsupported files"
# TODO could handle this with parallel.
readonly unsupportedCount=$(wc -l "$unsupportedFiles" | cut -d $' ' -f 1)
if [[ "$unsupportedCount" -eq '0' ]]; then
	log info "File: $unsupportedFiles  has no entries, skipping copy"
else
	log info "copying existing files over"
	for item in $(cat "$unsupportedFiles"); do
		split=(${item//::/$'\n'})
		copyUnsupportedFile "${split[0]}" "${split[1]}"
	done
fi

# TODO in order for this to work may need to export more functions for parallel to make use of them
export _loggingLevel _logFileLocation
export -f compressFileExt compressFile compressedFileExists addFileToCache log

readonly mp3Count=$(wc -l "$mp3Files" | cut -d $' ' -f 1)
if [[ "$mp3Count" -eq '0' ]]; then
	log info "File: $mp3Files has no entries, skipping compression"
else
	log info "starting parallel execution of compression"
	parallel --verbose --col-sep '::' --delimiter '\n' 'compressFileExt {#} {1} {2}' :::: "$mp3Files"
fi

printStatistics "$mp3Files"

unset -f compressFileExt compressFile compressedFileExists addFileToCache log
unset _loggingLevel _logFileLocation
