#!/usr/bin/env bash

# TODO fill out with auto complete logic

function _links_getFriendlyNames {
	:
	# TODO grep $linksDoc file for friendly name
	# TODO examples grep -E '^#.*' $linksDoc | sed 's/#//'
	# TODO will have to parse args for -f file
	# TODO if -f is not provided then default to $LINKSDOC var
	# TODO exit if file is empty
	local linkDoc="$1"

	local linkNames=$(grep -E '^#.*' "$linkDoc" | sed -E 's/^#[ ]?(.*)/\1/')
	printf '%s\n' "${linkNames[@]}"
}

function _links_processArg {
	:
	# TODO not sure what I'm gonna do with this here.
	# example processing link friendly names
	result=$(_links_getFriendlyNames "$linkDoc")
	while IFS=$'\n' read -r line; do
		echo "Line: $line"
	done <<<$result
}

function _links_auto_comp {
	local firstLevelOptions=('help' 'install' 'list' 'edit' '-h' '-w' '-c' '--help' '--file')
	local word="${COMP_WORDS[COMP_CWORD]}"
	# TODO figure out how I want autocomplete to work.
	# --file can only be provided once
	# argument after --file argument should be normal tab completion
	# help, install, list, and edit can only be provided with the --file argument
	# Only one of -w or -c can be provided
	# Might trim down the different help options.
	#if ((COMP_CWORD > 1)); then
	#	:
	#	# TODO check if first option is one of help, install, list, or edit then return
	#	# No other options allowd
	#else
	COMPREPLY=($(compgen -W "${firstLevelOptions[*]}" $word)) #"$(echo $word | sed 's/-/\\-/')"))
	return 0
	#fi
}

complete -F _links_auto_comp links
