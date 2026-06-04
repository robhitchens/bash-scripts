#!/usr/bin/env bash
# TODO add help doc
# TODO add install script
# Alternatively could work on a simple vim script function to poop out template

declare -g changeNumber="" title="" why="" what=()

function parseArgs {
	# TODO should probably add some guards against using mixed flags or providing the same flag twice.
	for ((i = 0; i < $#; i++)); do
		if [[ "${!i}" =~ ^--(.+)$ ]]; then
			local arg="${BASH_REMATCH[1]}"
			case "$arg" in
			changeNumber)
				((i++))
				changeNumber="${!i}"
				;;
			title)
				((i++))
				title="${!i}"
				;;
			why)
				((i++))
				why="${!i}"
				;;
			what)
				((i++))
				what+=("{!i}")
				;;
			*)
				echo "Unrecognized option: $i" >&2
				;;
			esac
		fi
		if [[ "${!i}" =~ ^-(.+)$ ]]; then
			local arg="${BASH_REMATCH[1]}"
			case "$arg" in
			c)
				((i++))
				changeNumber="${!i}"
				;;
			t)
				((i++))
				title="${!i}"
				;;
			W)
				((i++))
				why="${!i}"
				;;
			w)
				((i++))
				what+=("${!i}")
				;;
			esac
		fi
	done
}

function formatWhats {
	for ((i = 0; i < ${#what[@]}; i++)); do
		echo "- ${what[i]}"
	done
}

function main {
	parseArgs "$@"
	local template=":changeNumber:: :title:

Why:

:why:

What:

:what:
"
	if [[ -n "$changeNumber" ]]; then
		template="${template/:changeNumber:/$changeNumber}"
	fi
	if [[ -n "$title" ]]; then
		template="${template/:title:/$title}"
	fi
	if [[ -n "$why" ]]; then
		template="${template/:why:/$why}"
	fi
	if ((${#what[@]} > 0)); then
		template="${template/:what:/$(formatWhats)}"
	fi
	echo "$template"
}

main "$@"
