#!/usr/bin/env bash

function _complete {
	local word="${COMP_WORDS[COMP_CWORD]}"
	#local list=$(find . -type f -iname '*.xml')
	COMPREPLY=($(compgen -W "$(find . -type f -iname '*.xml')" "${COMP_WORDS[COMP_CWORD]}"))
}

function todo {
	echo "comp words: ${COMP_WORDS[@]}"
	echo "comp reply: ${COMPREPLY}"
}

complete -F _complete todo

export -f todo _complete
