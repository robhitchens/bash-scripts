#!/usr/bin/env bash

# TODO should implement "mocking" by allowing a binary or function to be aliased within the scope of a test.
# doing this may require some clever use of eval to assemble everything prior to running the test and using eval to execute the test.
# TODO could add assertAll which takes a semi-colon separated array of assert statements as strings

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
	equals)
		#if [[ "$actual" == "$expected" ]]; then
		if [[ "$(diff -w <(echo "$expected") <(echo "$actual") | wc -l)" == '0' ]]; then
			return 0
		else
			#echo "Expected '$expected', but got '$actual'" >&2
			echo "Actual did not match expected" >&2
			diff --color=auto -w -U 10 <(echo "$expected") <(echo "$actual") >&2
			return 2
		fi
		;;
	matches)
		# TODO may change to just a simple $string matches "$regex"
		#FIXME: this doesn't quite work with multiline regex.
		#might just implement a sed replace and compare.
		#FIXME: need to be able to handle more substitutions.
		local substitutions=("$(echo "$expected" | grep -nE 's/(.*)/(.*)/')")
		for sub in "${substitutions[@]}"; do
			local line="$(echo "$sub" | sed -E -s 's/^(.*):(.*)/\1/')"
			local subCommand="$(echo "$sub" | sed -E -s 's:^.*(s/(.*)/(.*)/).*$:\1:')"
			actual="$(echo "$actual" | sed -E "$line$subCommand")"
		done
		#if [[ $(echo "$actual" | grep -E "$expected" | wc -l) == '1' ]]; then
		#FIXME this won't work as implemented.
		if [[ "$actual" == "$expected" ]]; then
			return 0
		else
			echo "Expected actual '$actual' to match '$expected', but did not" >&2
			return 2
		fi
		;;
	*)
		echo "Unsupported assertion '$2'" >&2
		exit 1
		;;
	esac
}

function verify {
	# TODO fillout
	# example use verify "mockFunction" called $times
	# example use verify "mockFunction" called $times with "args"
	echo "not yet implemented"
}

function mock {
	# TODO fillout
	# will need to collect stats on invocations
	# example use mock initialize "functionName"
	# example use mock when "functionName" then echo "some value"
	# example use mock when "functionName" then return $returnCode
	# example use mock when "functionName" then exit $exitCode
	# example use mock ...
	echo "not yet implemented"
}

#Internal function to clear mock behavior after each test run
function _bsUnitLib_mocksClear {
	# TODO implement
	echo "not yet implemented"
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

export -f assert mock spy verify
