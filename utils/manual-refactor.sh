#!/usr/bin/env bash
# TODO leftover
function vimLine() {
	local fileName="$1"
	local lineNum="$2"
	vim +$2 $1 -c 'normal zt'
}
function manualRefactor() {
	local pattern="$1"
	local dir="$2"
	# TODO add check for arg length
	# TODO should shift args if -p is detected first
	while getopts "p" opt; do
		case $opt in
		p) local preview=1 ;;
		*)
			echo "unknown option: $opt" >&2
			exit 1
			;;
		esac
	done
	local commands=""
	while read -r line; do
		local separated=($(echo "$line" | tr ':' ' '))
		local file="${separated[0]}"
		local lineNum="${separated[1]}"
		if [[ -n "$commands" ]]; then
			commands="$commands && vim +$lineNum $file -c 'normal zt'"
		else
			commands="vim +$lineNum $file -c 'normal zt'"
		fi
	done < <(grep -n -r -E "$pattern" $2)
	if [[ -z "$commands" ]]; then
		echo "Nothing to edit" >&2
		exit 0
	fi
	if ((preview > 0)); then
		echo "$commands"
	else
		eval "$commands"
	fi
}

function installScript {
	local symlink='/usr/local/bin/manualRefactor'
	# TODO should probably prompt user before nuking existing symlink file.
	if [[ -f $symlink ]]; then
		echo "link [$symlink] already exists. Removing..."
		rm -f $symlink
	fi

	local scriptLocation=$(find . -type f -iname 'manual-refactor.sh' | xargs realpath --relative-to=/ | sed -E 's/(.*)/\/\1/')

	# TODO should error out if script can't be found.
	echo "linking $scriptLocation -> $symlink"
	ln -s $scriptLocation $symlink
}

if [[ "$1" == 'install' ]]; then
	installScript
else
	manualRefactor "$@"
fi
