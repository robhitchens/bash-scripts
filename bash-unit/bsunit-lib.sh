#!/usr/bin/env bash
shopt -s expand_aliases

# TODO should implement "mocking" by allowing a binary or function to be aliased within the scope of a test.
# doing this may require some clever use of eval to assemble everything prior to running the test and using eval to execute the test.
# TODO could add assertAll which takes a semi-colon separated array of assert statements as strings

readonly _bsUnitLib_mockDir='/tmp/bsunit-lib'
readonly _bsUnitLib_mockLogFile="$_bsUnitLib_mockDir/mockInvocations.log"
function _bsUnitLib_initializeTempFolder {
	if [[ ! -d "$_bsUnitLib_mockDir" ]]; then
		mkdir -p "$_bsUnitLib_mockDir"
	fi

	if [[ ! -f "$_bsUnitLib_mockLogFile" ]]; then
		touch "$_bsUnitLib_mockLogFile"
	else
		echo -n $null >"$_bsUnitLib_mockLogFile"
	fi
}

function assert {
	# TODO fillout
	# example use assert $someVar equals $someValue
	# example use assert $someVar notEquals $someValue
	# example use assert $someVar isEmpty
	# example use assert $someVar isNotEmpty
	# example use assert ...
	local actual="$1"
	local expected="$3"
	case "$2" in
	isEmpty)
		if [[ -z "$actual" ]]; then
			return 0
		else
			echo "Expecting actual to be empty, but was '$actual'" >&2 &&
				return 2
		fi
		;;
	isNotEmpty)
		if [[ -n "$actual" ]]; then
			return 0
		else
			echo "Expecting actual to not be empty, but was '$actual'" >&2 &&
				return 2
		fi
		;;
	equals)
		if [[ "$actual" == "$expected" ]]; then
			return 0
		else
			echo "Expected actual to equal '$expected', but was '$actual'" >&2 &&
				diff --color=auto -U 20 <(echo "$expected") <(echo "$actual") >&2 &&
				return 2
		fi
		;;
	equalsIgnoringWhitespace)
		if [[ "$(diff -w <(echo "$expected") <(echo "$actual") | wc -l)" == '0' ]]; then
			return 0
		else
			echo "Actual did not match expected" >&2 &&
				diff --color=auto -w -U 20 <(echo "$expected") <(echo "$actual") >&2 &&
				return 2
		fi
		;;
	matches)
		if [[ "$(echo "$actual" | grep -E "$expected" | wc -l)" == '0' ]]; then
			return 0
		else
			echo "Expected actual '$actual' to match '$expected', but did not" >&2 &&
				return 2
		fi
		;;
	*)
		echo "Unsupported assertion '$2'" >&2 &&
			exit 1
		;;
	esac
}

# TODO could just store as delimited string in _bsUnitLib_mocks
declare -A _bsUnitLib_mocks
# update label to maintain line numbers in file.
declare -A _bsUnitLib_mockInvocations

#Internal function for aliasing mocked behavior
# TODO this doesn't seem to really be needed, should set alias in initialize and have separate function for setting behavior.
function _bsUnitLib_aliasMock {
	local command="$1"
	#_bsUnitLib_mocks[$command]='echo "default mock behavior"'
	#eval "function cat {_bsUnitLib_invokeMock \"$command\" }"
	alias $command="_bsUnitLib_invokeMock \"$command\""
	# TODO, unless I can figure out why this isn't working may have to switch to dumping mock state in file and just keep index in memory.
	# alias command may be running in a sub shell which means state changes won't cascade back up, so will have to rely on a file
	_bsUnitLib_mockInvocations[$command]="0"
}

function mock {
	# TODO fillout
	# will need to collect stats on invocations
	# example use mock initialize "functionName"
	# example use mock when "functionName" then echo "some value"
	# example use mock when "functionName" withArgs "arg strings" then ...
	# example use mock when "functionName" withArgs "argument matchers?" then ...
	# example use mock when "functionName" then do "eval string"
	# example use mock when "functionName" then do functionRef
	# example use mock when "functionName" then return $returnCode
	# example use mock when "functionName" then exit $exitCode
	# example use mock ...
	local command="$1"
	case "$command" in
	initialize)
		_bsUnitLib_initializeTempFolder
		# only supporting single function for now
		local functionName="$2"
		_bsUnitLib_aliasMock "$functionName"
		;;
	when)
		# sub commands thenEcho, thenReturn, and thenExit? or then $behaviorStub i.e. echo, do, return, exit
		local func="$2"
		echo "funcname $func" >&2
		local subCommands=(${@:3})
		echo "subcommands: ${subCommands[@]}" >&2
		case "${subCommands[0]}" in
		then)
			case "${subCommands[1]}" in
			# TODO need to figure out how to maintain whitespacing for strings passed in as arg to echo
			echo)
				local echoArgs=(${subCommands[@]:2})
				_bsUnitLib_mocks[$func]="echo '${echoArgs[@]}'"
				echo "mock behavior: ${_bsUnitLib_mocks[$func]}"
				;;
			*) echo "unsupported sub command ${subCommands[1]}" >&2 ;;
			esac
			;;
		*) echo "unsupported sub command ${subCommands[@]}" >&2 ;;
		esac
		;;
	*) echo "command $command is not supported" >&2 ;;
	esac
}

function _bsUnitLib_updateInvocationStats {
	# Future note: use sed "1,3p" file.txt to get a range of lines. may be useful for invocation information.
	# TODO assuming that mock invocation file already exists.
	local command="$1"
	local lineNum="${_bsUnitLib_mockInvocations[$command]}"
	local line=$(sed -n "${lineNum}p" "$_bsUnitLib_mockLogFile")
	local regex=".*[:]([0-9]+)"
	if [[ "$line" =~ $regex ]]; then
		local count="${BASH_REMATCH[1]}"
		((count++))
		# FIXME untested
		# sed -i -E -s '3c\mock:1' /tmp/scratch/test.log
		# sed -i -E -s "${lineNum}c/:([0-9]+)/:$count"
	fi
	# check for file
	# retrieve invocation line
	# split to get count
	# update count
	# write back updated line, can use sed for this, either include specific line in substitution or just use a global replacement pattern.
}

function _bsUnitLib_getInvocationStats {
	# TODO assuming that mock invocation file already exists.
	local command="$1"
	local lineNum="${_bsUnitLib_mockInvocations[$command]}"
	local line=$(sed -n "${lineNum}p" "$_bsUnitLib_mockLogFile")
	local regex=".*[:]([0-9]+)"
	if [[ "$line" =~ $regex ]]; then
		echo "${BASH_REMATCH[1]}"
	else
		exit 1
	fi
}

#Internal function for aliasing mocked behavior
function _bsUnitLib_invokeMock {
	# TODO aggregate function invocations for verify
	local command="$1"
	local mockedFunction=${_bsUnitLib_mocks[$command]}
	# FIXME somehow this is not cascading up
	#local invocationCount=${_bsUnitLib_mockInvocations[$command]}
	#if [[ "$invocationCount" == '' ]]; then
	#	((invocationCount = 0))
	#fi
	#((invocationCount += 1))
	#_bsUnitLib_mockInvocations[$command]="$invocationCount"
	#((_bsUnitLib_mockInvocations[$command]++))
	#echo "invocationCount: $invocationCount, ${_bsUnitLib_mockInvocations[$command]}" >&2
	_bsUnitLib_updateInvocationStats "$command"
	eval "$mockedFunction"
	# TODO capture return code?
}

#Internal function to clear mock behavior after each test run
function _bsUnitLib_mocksClear {
	# TODO implement
	echo "mocksClear invoked" >&2
	echo "not yet implemented" >&2
}

function verify {
	# TODO fillout
	# example use verify "mockFunction" called $times
	# example use verify "mockFunction" called $times with "args"
	# example use verify "mockFunction" called with "args"
	# example use verify "mockFunction" called never
	local command="$1"
	# TODO temporary implementation
	local subCommand="$2"
	local val="$3"
	echo "mockInvocations: ${_bsUnitLib_mockInvocations[$command]}" >&2
	if [[ "$val" == ${_bsUnitLib_mockInvocations[$command]} ]]; then
		return 0
	else
		echo "expected invocation of $command to have been called $val times, but was ${_bsUnitLib_mockInvocations[$command]}" >&2
		return 1
	fi
}

function spy {
	# TODO fillout, getting a little ambitious with this.
	# will need to collect stats on invocations
	# example use spy ...
	echo "not yet implemented"
}

#Internal function to clear spys behavior after each test run
function _bsUnitLib_spysClear {
	# TODO implement
	echo "not yet implemented"
}

# NOTE: if creating internal functions may have to move or merge into single script.

export -f assert mock spy verify _bsUnitLib_invokeMock
