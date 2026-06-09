#!/usr/bin/env bash
# TODO add help doc
# TODO add install script
# Alternatively could work on a simple vim script function to poop out template

declare -g changeNumber="" title="" why="" what=() echoHelp=false install=false

function fullDoc {
	cat <<EOF
Usage:
  git-commit-template [OPTS]
  gct [OPTS]

Synopsis:
  git-commit-template poops out a formatted template to stdout

Description:

Options:
  -h|--help                             Prints help doc to stdout
  -i|--install                          Installs script under /usr/local/bin
  -c|--changeNumber
  -t|--title
  -W|--why
  -w|--what
EOF
}

function parseArgs {
	# TODO should probably add some guards against using mixed flags or providing the same flag twice.
	if (($# == 0)); then
		echoHelp=true
		return 0
	fi

	for ((i = 0; i < $#; i++)); do
		if [[ "${!i}" =~ ^--(.+)$ ]]; then
			local arg="${BASH_REMATCH[1]}"
			case "$arg" in
			help)
				echoHelp=true
				return 0
				;;
			install)
				install=true
				return 0
				;;
			changeNumber)
				((i++))
				if [[ -z "$changeNumber" ]]; then
					changeNumber="${!i}"
				else
					echo "changeNumber already set" >&2
				fi
				;;
			title)
				((i++))
				if [[ -z "$title" ]]; then
					title="${!i}"
				else
					echo "title already set" >&2
				fi
				;;
			why)
				((i++))
				if [[ -z "$why" ]]; then
					why="${!i}"
				else
					echo "why already set" >&2
				fi
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
			h)
				echoHelp=true
				return 0
				;;
			i)
				install=true
				return 0
				;;
			c)
				((i++))
				if [[ -z "$changeNumber" ]]; then
					changeNumber="${!i}"
				else
					echo "changeNumber already set" >&2
				fi
				;;
			t)
				((i++))
				if [[ -z "$title" ]]; then
					title="${!i}"
				else
					echo "title already set" >&2
				fi
				;;
			W)
				((i++))
				if [[ -z "$why" ]]; then
					why="${!i}"
				else
					echo "why already set" >&2
				fi
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

function installScript {
	local symlink='/usr/local/bin/git-commit-template'
	local symlink_short='/usr/local/bin/gct'
	# TODO should probably prompt user before nuking existing symlink file.
	if [[ -f $symlink || -f $symlink_short ]]; then
		echo "Removing existing links: $symlink, $symlink_short" >&2
		rm -f $symlink $symlink_short
	else
		local scriptLocation=$(find . -type f -iname 'git-commit-template.sh' | xargs realpath --relative-to=/ | sed -E 's/(.*)/\/\1/')
		# TODO should error out if script can't be found.
		echo "Adding symlink: $symlink"
		ln -s $scriptLocation $symlink
		echo "Adding symlink: $symlink_short"
		ln -s $scriptLocation $symlink_short
	fi
}

function main {
	parseArgs "$@"
	if [[ "$echoHelp" == "true" ]]; then
		fullDoc
		return 0
	fi
	if [[ "$installScript" == "true" ]]; then
		install
		return 0
	fi
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
	# TODO add length validation to title
	if [[ -n "$why" ]]; then
		template="${template/:why:/$why}"
	fi
	if ((${#what[@]} > 0)); then
		template="${template/:what:/$(formatWhats)}"
	fi
	echo "$template"
}

main "$@"
