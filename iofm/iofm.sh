#!/usr/bin/bash

# Notes: just doing a small prototype

function processTokens {
	# TODO read using readline
	# lazy detection if line starts with a ./ then its a parent directory.
	# The format of the output tokens will be [context: $folder] (action) args...
	local currentContext
	while IFS=$'\n' read -r line; do
		# If line starts with (action) then interpret arguments
		if [[ "$line" =~ (.*)[:]$ ]]; then
			currentContext="${BASH_REMATCH[1]}"
			echo "$line"
		elif [[ "$line" =~ [\(](.*)[\)]\ (.*) ]]; then
			echo "[context: $currentContext] (${BASH_REMATCH[1]}) ${BASH_REMATCH[2]}"
		elif [[ "$line" =~ ^[\|](.*) ]]; then
			:
			# Doing nothing at the moment
			# echo "comment: ${BASH_REMATCH[1]}"
		else
			echo "$line"
		fi
	done
}

function pipeCat {
	local parent="$1"
	local file="$2"
	while IFS=$'\n' read -r line; do
		echo "| $line"
	done < <(cat "$parent/$file")
}

function commentOutput {
	while IFS=$'\n' read -r line; do
		echo "| $line"
	done
}

function doAction {
	local arr=("$@")
	local context="${arr[0]}"
	local action="${arr[1]}"
	local args="${arr[@]:2}"
	# TODO need to add error handling.
	local errorMsg
	case "$action" in
	c)
		echo "$args"
		pipeCat "$context" "$args"
		;;
	h)
		echo "$TODO implement head function" >&2
		;;
	t)
		echo "$TODO implement tail function" >&2
		;;
	to)
		touch "$context/$args"
		echo "$args"
		;;
	cp)
		echo "| copied $args"
		echo "TODO implement copy function" >&2
		;;
	mk)
		echo "$args"
		echo "TODO implement mkdir function" >&2
		;;
	d)
		if [[ -f "$context/$args" ]]; then
			errorMsg="$(rm "$context/$args")"
			echo "| deleted $args"
		else
			echo "| Failed to delete $args"
			commentOutput < <(echo "$errorMsg")
		fi
		;;
	dr)
		if [[ -d "$context/$args" ]]; then
			errorMsg="$(rm -r "$context/$args")"
			echo "| deleted $context/$args"
		else
			echo "| Failed to delete $context/$args"
			commentOutput < <(echo "$errorMsg")
		fi
		;;
		# TODO implement (q) and (a) confirmation prompts
	esac
}

function main {
	if [[ -t 0 ]]; then
		ls -R
	else
		while read -r token; do
			if [[ "$token" =~ \[context:\ (.*)]\ [\(](.*)[\)]\ (.*) ]]; then
				local context="${BASH_REMATCH[1]}"
				local action="${BASH_REMATCH[2]}"
				local args="${BASH_REMATCH[3]}"
				doAction "$context" "$action" $args
			else
				echo "$token"
			fi
		done < <(processTokens)
	#local tokens="$(processTokens)"
	#echo "${tokens[@]}"
	fi
}

main "$@"
