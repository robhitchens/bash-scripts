#!/usr/bin/env bash
# TODO add help doc
# TODO add install script
# Alternatively could work on a simple vim script function to poop out template

declare -g changeNumber="" title="" why="" what=() echoHelp=false install=false manual=false

function fullDoc {
	cat <<EOF
Usage:
  git-commit-template [-h | --help] [-i | --install] [-c | --changeNumber <value>] 
                      [-t | --title <value>] [-W | --why <value>] [-w | --what <value>]
  gct [-h | --help] [-i | --install] [-c | --changeNumber <value>] 
      [-t | --title <value>] [-W | --why <value>] [-w | --what <value>]

Synopsis:
  git-commit-template writes a formatted commit message template to stdout.

Description:
  git-commit-template is a tool for generating a template commit message following
  an opinionated format for a first commit on a branch to be squash merged.

  The template contains placeholder values for :changeNumber: :title: :what: and :why:.
  While the properties change number, title, and what accepts only a single value, the 
  :why: property can accept multiple values (provided in the form of [-w value]...).

  TODO add length validation for title line.
  TODO add processing for stdin.
  TODO add line wrap auto formatting for why and what parameters.

Options:
  -h|--help                             Prints help doc to stdout
  -i|--install                          Installs script under /usr/local/bin
  -c|--changeNumber                     Populates the change number of the commit message template. First instance sets the value.
  -t|--title                            Populates the title of the commit messaage template. First instance sets the value.
  -W|--why                              Populates the why section of the commit message template. First instance sets the value.
  -w|--what                             Populates the what section of the commit message template. Multiple 'what' options can be provided; instances will be formatted as a dash denoted list.
EOF
}

function parseArgs {
	# TODO should probably add some guards against using mixed flags or providing the same flag twice.
	if (($# == 0)); then
		manual=true
		return 0
	fi

	for ((i = 1; i < $# + 1; i++)); do
		local arg="${!i}"
		if [[ "$arg" =~ ^--(.+)$ || "$arg" =~ ^-(.+)$ ]]; then
			arg="${BASH_REMATCH[1]}"
			case "$arg" in
			help | h)
				echoHelp=true
				return 0
				;;
			install | i)
				install=true
				return 0
				;;
			changeNumber | c)
				((i++))
				if [[ -z "$changeNumber" ]]; then
					changeNumber="${!i}"
				else
					echo "changeNumber already set" >&2
				fi
				;;
			title | t)
				((i++))
				if [[ -z "$title" ]]; then
					title="${!i}"
				else
					echo "title already set" >&2
				fi
				;;
			why | W)
				((i++))
				if [[ -z "$why" ]]; then
					why="${!i}"
				else
					echo "why already set" >&2
				fi
				;;
			what | w)
				((i++))
				what+=("${!i}")
				;;
			*)
				echo "Unrecognized option: $i" >&2
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
	if [[ $echoHelp == true ]]; then
		fullDoc
		return 0
	fi
	if [[ $install == true ]]; then
		installScript
		return 0
	fi
	local template=":changeNumber:: :title:

Why:

:why:

What:

:what:
"
	if [[ $manual == true ]]; then
		echo "$template"
		return 0
	fi
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
