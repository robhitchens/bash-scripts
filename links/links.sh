#!/usr/bin/env bash

declare -A flags
declare -i skipCount

function hereDoc {
	# TODO document global var in hereDoc ($WINBROWSER, $CLIBROWSER, $BROWSER)
	# TODO document usage
	# TODO document options
	# TODO document interface
	cat <<-EOF
		Usage:
		  links [OPTS] [LINKNAME]

		Synopsis:
		  links is a simple utility to open links saved in a text file in a browser

		Description:
		  If no option for a browser is provided, then the bash default \$BROWSER will be used.
		  Default link doc can be set with LINKSDOC global variable

		Options:
		  --help|-h                         Prints help doc to stdout
		  --install                         Installs the script under /usr/local/bin and auto complete script under ...
		  --list|-l                         Lists out link headers from link doc
		  --edit|-e                         Opens up link doc using \$EDITOR
		  --file|-f                         Link file to be searched                                
		  --win|-w                          Opens link using \$WINBROWSER variable
		  --cli|-c                          Opens link using \$CLIBROWSER variable
	EOF
}

function getLink {
	local linkName="$1"
	local linkDoc="$2"

	local linkVal="$(grep -A1 -i "$linkName" "$linkDoc" | grep -v -E '^#.*')"

	if (($(echo "$linkVal" | wc -l) > 1)); then
		echo "Duplicate values returned for link name '$linkName'" >&2
		# TODO add support to allow interactive selection
		return 1
	else
		echo "$linkVal"
	fi

	# TODO grep $LINKSDOC for link friendly name, extract line number
	# TODO increment line number by 1
	# TODO get next line from grep output.
	# TODO alternatively, could utilize grep -A1 to get the link
	# TODO echo link.
	# TODO example: cat ~/links | grep -A1 -i '# azure portal' | grep -v -E '^#.*'
}

function catLinkHeaders {
	local linkDoc="$1"
	grep -E '^#' "$linkDoc" | sed -E 's/^#(.*)/\1/'
}

function install {
	# TODO get full path of script
	# TODO install main script in /usr/local/bin
	# TODO install auto-comp script in bash autocomplete folder
	local symlink='/usr/local/bin/links'
	local completion_symlink='/etc/bash_completion.d/links'
	if [[ -f $symlink ]]; then
		echo "Removing existing sym links: $symlink" >&2
		rm -f $symlink
	fi
	if [[ -f $completion_symlink ]]; then
		echo "Removing existing sym links: $completion_symlink" >&2
		rm -f "$completion_symlink"
	fi
	local scriptLocation=$(find . -type f -iname 'links.sh' | xargs realpath --relative-to=/ | sed -E 's/(.*)/\/\1/')
	echo "Adding symlink: $symlink"
	ln -s $scriptLocation $symlink

	local scriptLocation=$(find . -type f -iname 'links-auto-comp.sh' | xargs realpath --relative-to=/ | sed -E 's/(.*)/\/\1/')
	echo "Adding symlink: $completion_symlink"
	ln -s $scriptLocation $completion_symlink
}

function handleOneOffOptions {
	if [[ "$1" == '--help' || "$1" == '-h' || "$1" == '' ]]; then
		hereDoc
		return 0
	fi

	if [[ "$1" == '--install' ]]; then
		install
		return 0
	fi

	return 1
}

function setFlags {
	for ((i = 1; i <= $#; i++)); do
		local arg="${!i}"
		local flag="$(echo "$arg" | grep -E '^(\-\w{1}|\-{2}\w+)$')"
		if [[ -n $flag ]]; then
			case "$flag" in
			--win | -w)
				flags['win']=true
				((skipCount += 1))
				;;
			--cli | -c)
				flags['cli']=true
				((skipCount += 1))
				;;
			--list | -l)
				flags['list']=true
				((skipCount += 1))
				;;
			--edit | -e)
				flags['edit']=true
				((skipCount += 1))
				;;
			--file | -f)
				((i++))
				local file="${!i}"
				if [[ -n "${!i}" ]]; then
					local file="${!i}"
				fi
				flags['file']="$file"
				((skipCount += 2))
				;;
			*)
				echo "Unknown flag: $flag" >&2
				return 1
				;;
			esac
		fi
	done

	if [[ -z "${flags['file']}" ]]; then
		flags['file']="$LINKSDOC"
	fi
}

function main {
	# TODO parse arguemnts
	# TODO handle --help arg or no args, call hereDoc, and return
	# TODO handle install arg
	# TODO handle -w flag to open using $WINBROWSER var
	# TODO handle -c flag to open using $CLIBROWSER var
	# TODO handle -f flag to set $linksDoc variable
	# TODO handle default case of no flags by using $BROWSER var
	# TODO handle file pointer if provided
	# TODO invoke getLink with link friendly name and file pointer
	# TODO call $BROWSER with returned link if not empty
	# TODO return with error if empty.

	# TODO interface links [-w|-c] [-f file] [linkName]
	handleOneOffOptions "$@"
	if (($? == 0)); then
		return 0
	fi

	setFlags "$@"
	if (($? == 1)); then
		return 1
	fi

	if [[ -n "${flags['list']}" ]]; then
		catLinkHeaders "${flags['file']}"
		return 0
	elif [[ -n "${flags['edit']}" ]]; then
		$EDITOR "${flags['file']}"
		return 0
	fi

	((skipCount += 1))
	local linkName="${!skipCount}"
	local link="$(getLink "$linkName" "${flags['file']}")"

	if [[ -z "$link" ]]; then
		echo "Link name '$linkName' not found" >&2
		return 1
	fi

	if [[ "${flags['win']}" == true ]]; then
		if [[ -z "$WINBROWSER" ]]; then
			echo "Global variable WINBROWSER not set" >&2
			return 1
		fi
		"$WINBROWSER" "$link"
	elif [[ "${flags['cli']}" == true ]]; then
		if [[ -z "$CLIBROWSER" ]]; then
			echo "Global variable CLIBROWSER not set" >&2
			return 1
		fi
		"$CLIBROWSER" "$link"
	else
		"$BROWSER" "$link"
	fi

}

if [[ -z "$SCRIPTDEBUG" ]]; then
	main "$@"
	exit "$?"
fi
