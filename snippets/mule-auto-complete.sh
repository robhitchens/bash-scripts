#!/usr/bin/env bash

function _auto_complete {
	local firstLevelOptions=('test' 'dw')
	# Notes: CWORD is the current index of words trying to be completed
	#        COMP_WORD contains all of the current arguments presented during completion.
	local word="${COMP_WORDS[COMP_CWORD]}"
	if ((COMP_CWORD == 1)); then
		: # TODO handle completing first level options.
		COMPREPLY=($(compgen -W "${firstLevelOptions[*]}" "$word"))
		return 0
	fi
	# TODO need better comprehensive test expression.
	if [[ "${COMP_WORDS[1]}" == 'test' ]]; then
		: # TODO list completable test files
		# Assuming current working directory is root of project.
		if [[ -d 'src/test/munit' ]]; then
			local testFiles=($(find src/test/munit -type f -iname '*-suite.xml'))
			if [[ "$(printf "%s\\n" "${testsFiles[@]}" | grep "${COMP_WORDS[2]}" | wc -l)" == '1' ]]; then
				: # TODO find all tests within that file
			else
				# TODO need to fix need to iterate over testFiles and get base name for compreply
				# | xargs -I {} basename '{}'
				local baseNames=($(printf "%s\\n" "${testFiles[@]}" | xargs -I {} basename '{}'))
				COMPREPLY=($(compgen -W "${baseNames[*]}" "$word"))
			fi
			return 0
		fi
	elif [[ "${COMP_WORDS[1]}" == 'test' && -f "${COMP_WORDS[2]}" ]]; then
		local testFile="${COMP_WORDS[2]}"
		: # TODO parse test file for test names and collect into list
	fi
}

# TODO may have to rework this, should also see if I can attach complete to the symlink.
complete -F _auto_complete ml mule
