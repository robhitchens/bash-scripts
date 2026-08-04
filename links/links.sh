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
		  links [-h | --help] [--install] [-l | --list] [-e | --edit] [-f | --file fileName] [-w | --win] [-c | --cli] [LINKNAME] [SELECTION]

		Synopsis:
		  links is a simple utility to open links saved in a text file in a browser

		Description:
		  If no option for a browser is provided, then the bash default \$BROWSER will be used.
		  Default link doc can be set with LINKSDOC global variable
		      
		  If multiple matches come back for a given link name, then the urls of the matches 
		  will be shown as in indexed list and can be selected using 0-9.

		  To shortcut the indexed list of multiple matches the selection can be provided after
		  the linkname (e.g. "google 0" will select the first match with google in the header) 
		          
		Config:
		  LINKS_CONFIG_PRETTY_HEADERS     Boolean: if true, then --list (-l) will pipe output of headers through glow (if present)
		  LINKS_CONFIG_AUTO_BROWSER       Enum: values [win, cli, bro], will always prefer the selected option

		Options:
		  --help|-h                         Prints help doc to stdout
		  --install                         Installs the script under /usr/local/bin and auto complete script under ...
		  --list|-l                         Lists out link headers from link doc
		  --edit|-e                         Opens up link doc using \$EDITOR
		  --file|-f                         Link file to be searched                                
		  --win|-w                          Opens link using \$WINBROWSER variable
		  --cli|-c                          Opens link using \$CLIBROWSER variable
		  --bro|-b                          Opens link using \$BROWSER variable
	EOF
}

function getLink {
	local linkName="$1"
	local linkDoc="$2"
	local linkSel="$3"

	local linkVal=($(grep -A1 -i -E "^#(.*)$linkName(.*)$" "$linkDoc" | grep -v -E '^#.*' | grep -v -E '^[-]{2}'))

	if ((${#linkVal[@]} > 1)); then
		if [[ -n "$linkSel" ]]; then
			# TODO should add check to see if linkSel is valid or out of bounds.
			echo "${linkVal[$linkSel]}"
		else
			echo "Multiple values returned matching link name '$linkName'" >&2

			for ((i = 0; i < ${#linkVal[@]}; i++)); do
				echo "    $i. ${linkVal[i]}" >&2
			done

			echo -n "Choose the link you want [0-9]: " >&2
			read -r selection

			if [[ -n "$selection" ]]; then
				echo "${linkVal[$selection]}"
			else
				echo "No selection made" >&2
			fi
		fi
	else
		echo "${linkVal[0]}"
	fi

	# TODO grep $LINKSDOC for link friendly name, extract line number
	# TODO increment line number by 1
	# TODO get next line from grep output.
	# TODO alternatively, could utilize grep -A1 to get the link
	# TODO echo link.
	# TODO example: cat ~/links | grep -A1 -i '# azure portal' | grep -v -E '^#.*'
}

function listLinksWithHeaders {
	local linkTemplate="[:header:](:link:)"
	local linkDoc="$1"
	local link="$linkTemplate"
	local output=()

	while IFS=$'\n' read -r line; do
		if [[ "$line" == '--' ]]; then
			link="$linkTemplate"
			continue
		fi
		if [[ "$line" =~ ^#\ (.*) ]]; then
			link="${link/:header:/${BASH_REMATCH[1]}}"
		else
			link="${link/:link:/$line}"
		fi

		if ! [[ "$link" =~ .*:header:|:link:.* ]]; then
			output+=("$link")
		fi

	done <<<$(grep -A1 -E '^#' "$linkDoc")

	(for item in "${output[@]}"; do echo "$item"; done) | sort
}

function install {
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
		# TODO could add support for combination single tack flags i.e. -ef
		# TODO maybe replace grep with bash regex
		local flag="$(grep -E '^(\-\w{1}|\-{2}\w+)$' <<<"$arg")"
		# TODO would then need to remove '-' from flag, or skip over - and process options character by character
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

	# TODO should add some validation to guard against invalid option state.
}

function validateConfig {
	local errMsg=()
	if [[ -v LINKS_CONFIG_PRETTY_HEADERS ]]; then
		if [[ ! "$LINKS_CONFIG_PRETTY_HEADERS" =~ true|false ]]; then
			errMsg+=("Config variable LINKS_CONFIG_PRETTY_HEADERS is not a boolean value of true or false")
		fi
	fi

	if [[ -v LINKS_CONFIG_AUTO_BROWSER ]]; then
		if [[ ! "$LINKS_CONFIG_AUTO_BROWSER" =~ win|cli|bro ]]; then
			errMsg+=("Config variable LINKS_CONFIG_AUTO_BROWSER is not of enum string [win, cli, bro]")
		fi
	fi

	if [[ -n "$errMsg" ]]; then
		printf "%s\n" "${errMsg[@]}" >&2
		return 1
	else
		return 0
	fi
}

function main {
	handleOneOffOptions "$@"
	if (($? == 0)); then
		return 0
	fi

	setFlags "$@"
	if (($? == 1)); then
		return 1
	fi

	validateConfig
	if (($? == 1)); then
		return 1
	fi
	if [[ -n "${flags['list']}" ]]; then
		local output="$(listLinksWithHeaders "${flags['file']}")"
		if [[ $LINKS_CONFIG_PRETTY_HEADERS == true ]]; then
			echo "$output" | glow -w0
		else
			echo "$output"
		fi
		return 0
	elif [[ -n "${flags['edit']}" ]]; then
		$EDITOR "${flags['file']}"
		return 0
	fi

	((skipCount += 1))
	local linkName="${!skipCount}"
	((skipCount += 1))
	local linkSelection="${!skipCount}"
	local link="$(getLink "$linkName" "${flags['file']}" "$linkSelection")"

	if [[ -z "$link" ]]; then
		echo "Link name '$linkName' not found" >&2
		return 1
	fi

	if [[ "${flags['win']}" == true || "$LINKS_CONFIG_AUTO_BROWSER" == 'win' ]]; then
		if [[ -z "$WINBROWSER" ]]; then
			echo "Global variable WINBROWSER not set" >&2
			return 1
		fi
		"$WINBROWSER" "$link"
		return 0
	elif [[ "${flags['cli']}" == true || "$LINKS_CONFIG_AUTO_BROWSER" == 'cli' ]]; then
		if [[ -z "$CLIBROWSER" ]]; then
			echo "Global variable CLIBROWSER not set" >&2
			return 1
		fi
		"$CLIBROWSER" "$link"
		return 0
	else
		"$BROWSER" "$link"
		return 0
	fi

}

main "$@"
