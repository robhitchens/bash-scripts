#!/usr/bin/env bash

# FIXME this will probably break if I include flags for test.
function _test_complete {
	local word="$1"
	# Assuming current working directory is root of project.
	if [[ -d 'src/test/munit' ]]; then
		local testFiles=($(find src/test/munit -type f -iname '*-suite.xml'))
		if ((COMP_CWORD == 2)); then
			local baseNames=($(printf "%s\\n" "${testFiles[@]}" | xargs -I {} basename '{}'))
			COMPREPLY=($(compgen -W "${baseNames[*]}" "$word"))
		elif ((COMP_CWORD == 3)); then
			if [[ $(printf "%s\\n" "${testFiles[@]}" | xargs -I {} basename '{}' | grep "${COMP_WORDS[2]}" | wc -l) == '1' ]]; then
				# Need to resolve COMP_WORDS[2] to relative file path. Kinda cheating a bit, but I've already made some assumptions prior to here.
				local testMethods=($(grep 'munit:test name=' -i "src/test/munit/${COMP_WORDS[2]}" | sed -E 's/.*name="(.*)" .*$/\1/'))
				COMPREPLY=($(compgen -W "${testMethods[*]}" "$word"))
			fi
		fi
		return 0
	fi
}

function _auto_complete {
	local firstLevelOptions=('test' 'dw')
	# Notes: CWORD is the current index of words trying to be completed
	#        COMP_WORD contains all of the current arguments presented during completion.
	local word="${COMP_WORDS[COMP_CWORD]}"
	if ((COMP_CWORD == 1)); then
		COMPREPLY=($(compgen -W "${firstLevelOptions[*]}" "$word"))
		return 0
	fi
	# TODO need better comprehensive test expression.
	if [[ "${COMP_WORDS[1]}" == 'test' ]]; then
		_test_complete "$word"
		return 0
	fi
}

# Registering auto complete with ml and mule symlinks, assuming they're installed already.
complete -F _auto_complete ml mule
