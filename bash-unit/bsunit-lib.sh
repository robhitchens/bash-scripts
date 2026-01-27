#!/usr/bin/env bash

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

export -f assert
