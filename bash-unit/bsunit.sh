#!/usr/bin/env bash

# TODO need setup test runner in bsunit
# take file(s) | /dir as arguments (or functions inline) (or maybe invoke at the bottom of a test script and read in tests from the invoking script
# e.g. bsunit run mule-test.sh
# parse functions that end with the word test or comment annotated with TEST
# maybe also do something similar with setup and teardown functions.
# eval function and collect test results.
# print out stats at the end of run.
# if invoking bsunit as a top level process will need to source passed in test files.
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
declare -g passedTests
declare -g failedTests

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
	# TODO add check to see if no setup methods exist.
	if ((${#lineNumbers[@]} > 1)); then
		echo "test file [$input] contained [${#lineNumber[@]}] #SETUP methods. Only 1 setup method is supported" >&2
		exit 1
	fi
	local setup=$(head -n${lineNumbers[i]} "$input" | tail -n1 | sed -E 's/function (.*) \{$/\1/')
	echo "$setup"
}

function parseTeardown {
	local input="$1"
	local lineNumbers=($(grep -n '#TEARDOWN' $input | sed -E 's/(\d)*[:]#.*/\1+1/' | bc))
	# TODO add check to see if no teardown methods exist.
	if ((${#lineNumbers[@]} > 1)); then
		echo "test file [$input] contained [${#lineNumber[@]}] #TEARDOWN methods. Only 1 setup method is supported" >&2
		exit 1
	fi
	local teardown=$(head -n${lineNumbers[i]} "$input" | tail -n1 | sed -E 's/function (.*) \{$/\1/')
	echo "$teardown"
}

# TODO add support for #IGNORE annotation.

function streamOutput {
	while IFS=$'\n' read -r line; do
		echo "$line"
	done
}

function bsunit_testRunner {
	local testFile="$1"
	local setup=$(parseSetup "$testFile")
	local teardown=$(parseTeardown "$testFile")
	local unitTests=($(parseTests "$testFile"))
	for ((i = 0; i < ${#unitTests[@]}; i++)); do
		bsunit_sourcedTests+=(${unitTests[i]})
	done
	# TODO need to capture success and failure of each unit test for stats.
	# could add failed test names to a global array.
	# TODO should be able to pipe output to stdout while collecting results as long as variables are declared higher up.
	(
		source $testFile
		for unitTest in "${unitTests[@]}"; do
			echo "$bsunit_messageHeader running test: $unitTest"
			# TODO may want to capture output for failed test and tee it to a file.
			# if unit test has failed then take tee'd output and save it off somewhere, output in red in terminal.
			$setup
			# TODO need to handle if setup fails
			$unitTest
			if [[ $? == '0' ]]; then
				# TODO might have to append to temp file
				#passedTests+=("something")
				echo "$unitTest" >>$passedTests
			else
				# TODO might have to append to temp file.
				# failedTests+=("something")
				echo "$unitTest" >>$failedTests
			fi
			$teardown
			# TODO need to handle if teardown fails.
		done
	) | streamOutput
}

function outputResults {
	# TODO Add support for assertion failures, will require some additional thought, probably just another file that bsunit-lib manages.
	local numPass=$(cat $passedTests | wc -l)
	local numFail=$(cat $failedTests | wc -l)
	local formattedFailed="$(cat $failedTests | sed -E "s/(.*)/$bsunit_messageHeader - \1/")"
	# TODO add execution time.
	echo "$bsunit_messageHeader Test results:
$bsunit_messageHeader Total tests executed: ${#bsunit_sourcedTests[@]}
$bsunit_messageHeader Successful tests: $numPass/${#bsunit_sourcedTests[@]}
$bsunit_messageHeader Failed tests: $numFail/${#bsunit_sourcedTests[@]}
$formattedFailed
"
	# TODO add stats for ignored count as well
}

function makeTmpDir {
	local tempDir='/tmp/bsunit'
	if [[ ! -e "$tempDir" ]]; then
		mkdir -p "$tempDir"
		touch "$tempDir/passedTests.bs"
		touch "$tempDir/failedTests.bs"
	fi
	echo "$tempDir/passedTests.bs" "$tempDir/failedTests.bs"
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
	fi

	if [[ "$1" == 'run' ]]; then
		# maybe here check to see what was provided, source, and execute testRunner
		# could utilize grep to find which lines are annotated, simple increment by 1 to get the function name to execute.
		# after running each file, may want to see if there's a way to unsource a file or something.
		# could deal with isolating source by encapsulating in subshell while sourcing and running tests.
		local tmpFiles=($(makeTmpDir))
		passedTests=${tmpFiles[0]}
		failedTests=${tmpFiles[1]}
		if [[ -n "$2" ]]; then
			# TODO add check to see if files and directories are mixed. If so, exit with error.
			if [[ -f "$2" ]]; then
				# TODO expand to support multiple files.
				bsunit_testRunner "$2"
			elif [[ -d "$2" ]]; then
				# TODO expand to support multiple directories
				local testFiles=$(find "$2" -type f '*.test.sh')
				local length="${#testFiles[@]}"
				for ((i = 0; i < length; i++)); do
					# TODO should probably just use a for in loop
					bsunit_testRunner "${testFiles[((i))]}"
				done
			else
				# TODO handle case where test provided is single test.
				echo "else not yet handled"
			fi
		else
			echo "no tests found" &>2
			exit 1
		fi
		outputResults
		clearFile $passedTests
		clearFile $failedTests
	fi
}

bsunit_main "$@"
