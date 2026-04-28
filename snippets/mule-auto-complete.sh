#!/usr/bin/env bash

# TODO look into using /etc/bash_completion.d/ for installing auto-complete scripts.
# FIXME this will probably break if I include flags for test.
# TODO this works locally, but doesn't appear to work on my machine at work. Will need to investigate what's different.
function _mule_test_complete {
	local argStartIndex="$1"
	local word="$2"
	# Assuming current working directory is root of project.
	if [[ -d 'src/test/munit' ]]; then
		local testFiles=($(find src/test/munit -type f -iname '*-suite.xml'))
		if ((COMP_CWORD == (argStartIndex + 1))); then
			local baseNames=($(printf "%s\\n" "${testFiles[@]}" | xargs -I {} basename '{}'))
			COMPREPLY=($(compgen -W "${baseNames[*]}" "$word"))
		elif ((COMP_CWORD == (argStartIndex + 2))); then
			local fileIndex=$((argStartIndex + 1))
			if [[ $(printf "%s\\n" "${testFiles[@]}" | xargs -I {} basename '{}' | grep "${COMP_WORDS[fileIndex]}" | wc -l) == '1' ]]; then
				# Need to resolve COMP_WORDS[2] to relative file path. Kinda cheating a bit, but I've already made some assumptions prior to here.
				local testMethods=($(grep 'munit:test name=' -i "src/test/munit/${COMP_WORDS[fileIndex]}" | sed -E 's/.*name="(.*)" .*$/\1/'))
				COMPREPLY=($(compgen -W "${testMethods[*]}" "$word"))
			fi
		fi
		return 0
	fi
}

# TODO to make this work will need to write a mini completion engine, maybe during install could plop some kind of a map file in ~/.config/mule or something.
function _mule_httpRequest_complete {
	local argStartIndex="$1"
	local word="$2"
	local options=('b' 'body' 'h' 'headers' 'q' 'queryParams' 'u' 'uriParams')
	# FIXME: This works, but feels clunky.
	declare -A pairs
	pairs['b']='body'
	pairs['body']='b'
	pairs['h']='headers'
	pairs['headers']='h'
	pairs['q']='queryParams'
	pairs['queryParams']='q'
	pairs['u']='uriParams'
	pairs['uriParams']='u'

	if ((COMP_CWORD > (argStartIndex + 1))); then
		for ((i = argStartIndex + 1; i < COMP_CWORD; i++)); do
			local remove="${COMP_WORDS[$i]}"
			remove="($remove ${pairs[$remove]}|${pairs[$remove]} $remove)"
			options=($(echo "${options[@]}" | sed -E "s/$remove//"))
		done
	fi
	COMPREPLY=($(compgen -W "${options[*]}" "$word"))
}

function _mule_auto_comp {
	# Note: once a flag has been selected, should probably remove it from the list of options
	local firstLevelOptions=('-h' 'help' 'hr' 'http:request' 'install' 'test' 'dw' '-w' '-v' '-t' '-l')
	# Notes: CWORD is the current index of words trying to be completed
	#        COMP_WORD contains all of the current arguments presented during completion.
	local word="${COMP_WORDS[COMP_CWORD]}"
	local argStartIndex=1
	while ((argStartIndex < ${#COMP_WORDS[@]})); do
		if [[ "${COMP_WORDS[argStartIndex]}" =~ -\w ]]; then
			((argStartIndex++))
		else
			break
		fi
	done
	# TODO if first few options are flags, then need to advance the cursor until we reach a non flag arg
	if ((COMP_CWORD == argStartIndex)); then
		# FIXME if tab completing a flag, then need to find way to escape $word
		COMPREPLY=($(compgen -W "${firstLevelOptions[*]}" "$(echo $word | sed 's/-/\\-/')"))
		return 0
	fi
	case "$(echo "${COMP_WORDS[argStartIndex]}" | sed 's/-/\\:/')" in
	test)
		_mule_test_complete "$argStartIndex" "$word"
		return 0
		;;
		# FIXME: may need to refactor bash args to not contain ':'. Tab completion seems to break words with ':' into three separate words. i.e. http:request becomes http : request
	http:request | hr)
		_mule_httpRequest_complete "$argStartIndex" "$word"
		return 0
		;;
	*)
		return 0
		;;
	esac
}

# Registering auto complete with ml and mule symlinks, assuming they're installed already.
complete -F _mule_auto_comp ml mule
