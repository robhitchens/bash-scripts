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

	local linkNames=$(grep -E '^#.*' "$linkDoc" | sed -E 's/^#[ ]?(.*)/\1/' | sed 's/ /\\\\ /g')
	printf '%s\n' "${linkNames[@]}"
}

function _links_getLinkDoc {
	local linkDoc
	for ((i = 1; i < $#; i++)); do
		local arg="${!i}"
		if [[ '--file' == "$arg" ]]; then
			((i += 1))
			linkDoc="${!i}"
			if [[ -z "$linkDoc" ]]; then
				linkDoc="$LINKSDOC"
			fi
			break
		else
			linkDoc="$LINKSDOC"
		fi
	done
	echo "$linkDoc"
}

function _links_auto_comp {
	IFS=$'\n'
	local firstLevelOptions=('help' 'install' 'list' 'edit' '-h' '-w' '-c' '--help' '--file')
	local word="${COMP_WORDS[COMP_CWORD]}"
	# TODO figure out how I want autocomplete to work.
	# --file can only be provided once
	# argument after --file argument should be normal tab completion
	# help, install, list, and edit can only be provided with the --file argument
	# Only one of -w or -c can be provided
	# Might trim down the different help options.
	local linkDoc="$(_links_getLinkDoc "$@")"
	local friendlyNames=($(_links_getFriendlyNames "$linkDoc"))
	#if ((COMP_CWORD > 1)); then
	#	:
	#	# TODO check if first option is one of help, install, list, or edit then return
	#	# No other options allowd
	#else
	COMPREPLY=($(compgen -W "${friendlyNames[*]}" $word)) #"$(echo $word | sed 's/-/\\-/')"))
	return 0
	#fi
}

complete -F _links_auto_comp links
