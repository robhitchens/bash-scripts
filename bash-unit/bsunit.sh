#!/usr/bin/env bash

function bsunit_fullDoc {
	cat <<EOF
Usage:
  bsunit [OPTS] [COMMANDS...]

Synopsis:
  bsunit is a simple test runner for bash

Description:
  WIP: runs bsunit test files (*.test.sh)
  WIP: ex. bsunit run someTest.test.sh
  WIP: ex. bsunit run someTest.test.sh#someTest
  WIP: ex. bsunit run test/
  test functions can be denoted with function name ending in test or annotated with #TEST
  test setup function can be denoted with function name setup or annotated with #SETUP
  test teardown function can be denoted with function name teardown or annotated with #TEARDOWN

Options:
  -h|--help                             Prints help doc to stdout
  -v|--verbose                          Verbose flag for test runner
  -t|--timed                            Time flag for test runner
  -l|--loop                             Loop flag to set test runner to until SIGINT (Crtl+C) is sent

Commands:
  install                               Installs bsunit and bsunit-lib.sh
  help                                  Prints help doc to stdout
  run [file|dir]                        Runs a bsunit test file.          
EOF
}

declare -A bsunit_testResults
declare -a bsunit_sourcedTests
readonly bsunit_messageHeader="[BSUNIT]"
# FIXME: should be able to declare all of these as a single line.
declare -g passedTests
declare -g failedTests
declare -g assertionFailures
declare -g start
declare -g end

# TODO could expand #TEST annotation with [ ] to add additional attributes could be simply key=value config
# potential options would be ignore, exitsWithErrorCode
# Need to figure out if there's a try block in bash
# Looks like it's possible to use set -e, trap and a function to handle error scopes, would need to use in sub process only.

function parseTests {
	# TODO fill out
	# use grep to find #TEST,#SETUP, and #TEARDOWN lines in file
	# parse grep output to collect tests to run
	# parse grep output to get name of setup function
	# parse grep output to get name of teardown function
	# TODO add config file to ignore test files in dirs.
	local input="$1"
	local lineNumbers=($(grep -n '#TEST' $input | sed -E 's/(\d)*[:]#.*/\1+1/' | bc))
	local tests=()
	for ((i = 0; i < "${#lineNumbers[@]}"; i++)); do
		tests+=($(head -n${lineNumbers[i]} "$input" | tail -n1 | sed -E 's/function (.*) \{$/\1/'))
	done
	echo "${tests[@]}"
}

function parseSetup {
	local input="$1"
	local lineNumbers=($(grep -n '#SETUP' $input | sed -E 's/(\d)*[:]#.*/\1+1/' | bc))
	if ((${#lineNumbers[@]} > 1)); then
		echo "test file [$input] contained [${#lineNumber[@]}] #SETUP methods. Only 1 setup method is supported" >&2
		exit 1
	elif ((${#lineNumbers[@]} == 1)); then
		local setup=$(head -n${lineNumbers[i]} "$input" | tail -n1 | sed -E 's/function (.*) \{$/\1/')
		echo "$setup"
	else
		echo "No setup functions found" >&2
	fi
}

function parseTeardown {
	local input="$1"
	local lineNumbers=($(grep -n '#TEARDOWN' $input | sed -E 's/(\d)*[:]#.*/\1+1/' | bc))
	# TODO add check to see if no teardown methods exist.
	if ((${#lineNumbers[@]} > 1)); then
		echo "test file [$input] contained [${#lineNumber[@]}] #TEARDOWN methods. Only 1 setup method is supported" >&2
		exit 1
	elif ((${#lineNumbers[@]} == 1)); then
		local teardown=$(head -n${lineNumbers[i]} "$input" | tail -n1 | sed -E 's/function (.*) \{$/\1/')
		echo "$teardown"
	else
		echo "No teardown functions found" >&2
	fi
}

# TODO add support for #IGNORE annotation. or ignore property of #TEST
function bsunit_testRunner {
	local testFile="$1"
	local singleTest="$2"
	local setup=$(parseSetup "$testFile")
	local teardown=$(parseTeardown "$testFile")
	local unitTests=($(parseTests "$testFile"))
	if [[ "$singleTest" != '' ]]; then
		local found=0
		for ((i = 0; i < ${#unitTests[@]}; i++)); do
			if [[ "${unitTests[i]}" == "$singleTest" ]]; then
				found=1
				break
			fi
		done
		if ((found == 1)); then
			unitTests=("$singleTest")
		else
			echo "Unit test '$singleTest' not found in $testFile" >&2
			exit 1
		fi
	fi
	for ((i = 0; i < ${#unitTests[@]}; i++)); do
		bsunit_sourcedTests+=(${unitTests[i]})
	done

	(
		# TODO maybe set trap on RETURN signal and check to see if return code is 0 or not
		source $testFile
		for unitTest in "${unitTests[@]}"; do
			echo "$bsunit_messageHeader running test: $unitTest"
			# TODO may want to capture output for failed test and tee it to a file.
			# if unit test has failed then take tee'd output and save it off somewhere, output in red in terminal.
			if [[ -n "$setup" ]]; then
				$setup
			fi
			# TODO need to handle if setup fails
			# TODO need to tee error output to failures file, will require additional processing for results.
			$unitTest
			local exitCode="$?"
			if [[ "$exitCode" == '0' ]]; then
				echo "$unitTest" >>$passedTests
			elif [[ "$exitCode" == '1' ]]; then
				echo "$unitTest" >>$failedTests
			else
				echo "$unitTest" >>$assertionFailures
			fi
			if [[ -n "$teardown" ]]; then
				$teardown
			fi
			[[ $(type -t _bsUnitLib_mocksClear) == function ]] && _bsUnitLib_mocksClear
			# TODO need to handle if teardown fails.
		done
	)
}

function segmentEpoch {
	local epoch="$1"
	#local leadingZeros='s/^[0]+([0-9]+)/\1/'
	local epochSecondsNano=($(echo "$epoch" | tr '.' ' '))
	# TODO could probably cutdown on starting and killing processes by cating each calculation through a pipe into bc.
	if ((${#epochSecondsNano[@]} == 1)); then
		local hours=0
		local minutes=0
		local seconds=0
		local milli="$(echo "${epochSecondsNano[0]}/1000" | bc)"
		echo "$hours $minutes $seconds $milli"
	else
		local hours="$(echo "${epochSecondsNano[0]}/60/60%60" | bc)"
		local minutes="$(echo "${epochSecondsNano[0]}/60%60" | bc)"
		local seconds="$(echo "${epochSecondsNano[0]}%60" | bc)"
		local milli="$(echo "${epochSecondsNano[1]}/1000" | bc)"
		echo "$hours $minutes $seconds $milli"
	fi
}

function formatElapsedTime {
	#FIXME this function won't be able to handle clock rollover logic i.e. 23:59 -> 00:00
	#FIXME the calculations seem off, something is not getting evaluated correctly.
	local startTime="$1"
	local endTime="$2"
	#local sSeg=($(segmentTimestamp "$startTime"))
	#local eSeg=($(segmentTimestamp "$endTime"))

	# TODO need to rework logic here.
	#echo "$((${eSeg[0]} - ${sSeg[0]}))h $((${eSeg[1]} - ${sSeg[1]}))m $((${eSeg[2]} - ${sSeg[2]}))s $((${eSeg[3]} - ${sSeg[3]}))ms"
	local elapsed="$(echo "$end - $start" | bc)"
	local elapsedSegments=($(segmentEpoch "$elapsed"))

	echo "${elapsedSegments[0]}h ${elapsedSegments[1]}m ${elapsedSegments[2]}s ${elapsedSegments[3]}ms"
}

function outputResults {
	local numPass=$(cat $passedTests | wc -l)
	local numFail=$(cat $failedTests | wc -l)
	local numAssertionFail=$(cat $assertionFailures | wc -l)
	local numIgnored=0 #$(cat $ignoredTests | wc -l)
	local totalExecutedTests=$((numPass + numFail + numAssertionFail))
	local totalFoundTests=$((totalExecutedTests + numIgnored))
	local formattedFailed="$(cat $failedTests | sed -E "s/(.*)/$bsunit_messageHeader - \1/")"
	local formattedAssertFails="$(cat $assertionFailures | sed -E "s/(.*)/$bsunit_messageHeader - \1/")"

	echo "$bsunit_messageHeader Test results:
$bsunit_messageHeader Start Time: $(date +'%T.%3N' -d "@$start")
$bsunit_messageHeader End Time: $(date +'%T.%3N' -d "@$end")
$bsunit_messageHeader Total execution time: $(formatElapsedTime "$start" "$end")
$bsunit_messageHeader - Total tests executed: $totalExecutedTests/$totalFoundTests
$bsunit_messageHeader - Ignored tests:        $numIgnored/$totalFoundTests
$bsunit_messageHeader - Successful tests:     $numPass/$totalExecutedTests
$bsunit_messageHeader - Failed tests:         $numFail/$totalExecutedTests
$bsunit_messageHeader - Assertion failures:   $numAssertionFail/$totalExecutedTests"
	if [[ -n "$formattedAssertFails" ]]; then
		echo "$bsunit_messageHeader -------------------- Tests with failed assertions -------------------- 
$formattedAssertFails"
	fi
	if [[ -n "$formattedFailed" ]]; then
		echo "$bsunit_messageHeader -------------------- Failed tests ------------------------------------
$formattedFailed"
	fi
}

function makeTmpDir {
	local tempDir='/tmp/bsunit'
	if [[ ! -e "$tempDir" ]]; then
		mkdir -p "$tempDir"
		touch "$tempDir/passedTests.bs"
		touch "$tempDir/failedTests.bs"
		touch "$tempDir/assertionFailures.bs"
	fi
	echo "$tempDir/passedTests.bs" "$tempDir/failedTests.bs" "$tempDir/assertionFailures.bs"
}

function clearFile {
	local file="$1"
	echo -n $null >$file
}

function installScript {
	local symlink='/usr/local/bin/bsunit'
	local libSymlink='/usr/local/bin/bsunit-lib.sh'
	# TODO should probably prompt user before nuking existing symlink file.
	if [[ -f $symlink ]]; then
		echo "link [$symlink] already exists. Removing..."
		rm -f $symlink
	fi

	if [[ -f $libSymlink ]]; then
		echo "link [$libSymlink] already exists. Removing..."
		rm -f $libSymlink
	fi

	local scriptLocation=$(find . -type f -iname 'bsunit.sh' | xargs realpath --relative-to=/ | sed -E 's/(.*)/\/\1/')
	local libLocation=$(find . -type f -iname 'bsunit-lib.sh' | xargs realpath --relative-to=/ | sed -E 's/(.*)/\/\1/')

	# TODO should error out if script can't be found.
	echo "linking $scriptLocation -> $symlink"
	ln -s $scriptLocation $symlink
	echo "linking $libLocation -> $libSymlink"
	ln -s $libLocation $libSymlink
	# assuming a first time use it would be executed where the script is located.
	# should also check to see if the symlink already exists.
	# TODO not sure if starting point for find should be the current directory or start at root
	# TODO could attempt to find locally first before jumping up to root.
}

function bsunit_main {
	# TODO need to handle case were first argument is not a known option
	if [[ "$1" == 'help' || "$1" == '--help' || "$1" == '' ]]; then
		bsunit_fullDoc
		exit 0
	fi

	if [[ "$1" == 'install' ]]; then
		installScript
		exit 0
	fi

	if [[ "$1" == 'run' ]]; then
		start="$EPOCHREALTIME"
		local tmpFiles=($(makeTmpDir))
		passedTests=${tmpFiles[0]}
		failedTests=${tmpFiles[1]}
		assertionFailures=${tmpFiles[2]}
		# clearing in case of a previous failed run.
		clearFile $passedTests
		clearFile $failedTests
		clearFile $assertionFailures

		if [[ -n "$2" ]]; then
			# TODO add check to see if files and directories are mixed. If so, exit with error.
			if [[ -f "$2" ]]; then
				# TODO expand to support multiple files.
				echo "$bsunit_messageHeader running test suite: $2"
				bsunit_testRunner "$2"
			elif [[ -d "$2" ]]; then
				# TODO expand to support multiple directories
				echo "Running tests in dir: $2" >&2
				local testFiles=($(find "$2" -type f -name '*.test.sh'))
				local length="${#testFiles[@]}"
				for ((i = 0; i < length; i++)); do
					echo "$bsunit_messageHeader running test suite: ${testFiles[i]}"
					(bsunit_testRunner "${testFiles[((i))]}")
				done
			else
				local arr=($(echo "$2" | sed 's/#/ /'))
				if ((${#arr[@]} != 2)); then
					echo "Invalid test function syntax: $2" >&2
					exit 1
				fi
				echo "$bsunit_messageHeader running test suite: ${arr[0]}"
				bsunit_testRunner "${arr[0]}" "${arr[1]}"
				# TODO handle case where test provided is single test.
			fi
		else
			echo "no tests found" &>2
			exit 1
		fi
		end="$EPOCHREALTIME"
		outputResults
	fi
}

bsunit_main "$@"
