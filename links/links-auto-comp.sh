#!/usr/bin/env bash

# TODO fill out with auto complete logic

function getFriendlyNames {
	:
	# TODO grep $linksDoc file for friendly name
	# TODO examples grep -E '^#.*' $linksDoc | sed 's/#//'
	# TODO will have to parse args for -f file
	# TODO if -f is not provided then default to $LINKSDOC var
	# TODO exit if file is empty
}

function _links_auto {
	local firstLevelOptions=('help' 'install' 'list' 'edit' '-h' '-w' '-c' '--help' '--file')
	local word="${COMP_WORDS[COMP_CWORD]}"
	# TODO figure out how I want autocomplete to work.
	# --file can only be provided once
	# argument after --file argument should be normal tab completion
	# help, install, list, and edit can only be provided with the --file argument
	# Only one of -w or -c can be provided
	# Might trim down the different help options.
}

complete -F _links_auto links
