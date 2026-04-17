#!/usr/bin/env bash

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
		  If no option for a browser is provided, then the bash default \$BROWSER will be used

		Options:
		  --help                            Prints help doc to stdout
		  -w                                Opens link using \$WINBROWSER variable
		  -c                                Opens link using \$CLIBROWSER variable
		  -f|--file                         Link file to be searched                                
		Commands:
		  install                           Installs the script under /usr/local/bin and auto complete script under ...
		  help                              Prints help doc to stdout
	EOF
}

function getLink {
	local linkName="$1"
	local linkDoc="$2"

	local linkVal="$(grep -A1 -i "$linkName" | grep -v -E '^#.*')"

	echo "$linkVal"

	# TODO grep $LINKSDOC for link friendly name, extract line number
	# TODO increment line number by 1
	# TODO get next line from grep output.
	# TODO alternatively, could utilize grep -A1 to get the link
	# TODO echo link.
	# TODO example: cat ~/links | grep -A1 -i '# azure portal' | grep -v -E '^#.*'
}

function install {
	:
	# TODO get full path of script
	# TODO install main script in /usr/local/bin
	# TODO install auto-comp script in bash autocomplete folder
}

function main {
	:
	# TODO parse arguemnts
	# TODO handle --help arg or no args, call hereDoc, and exit
	# TODO handle install arg
	# TODO handle -w flag to open using $WINBROWSER var
	# TODO handle -c flag to open using $CLIBROWSER var
	# TODO handle -f flag to set $linksDoc variable
	# TODO handle default case of no flags by using $BROWSER var
	# TODO handle file pointer if provided
	# TODO invoke getLink with link friendly name and file pointer
	# TODO call $BROWSER with returned link if not empty
	# TODO exit with error if empty.

	# TODO interface links [-w|-c] [-f file] [linkName]
	if [[ "$1" == 'help' || "$1" == '--help' || "$1" == '' ]]; then
		hereDoc
		exit 0
	fi

	if [[ "$1" == 'install' ]]; then
		install
		exit 0
	fi

	local skipCount=0
	while getopts "wcf" flag; do
		case "$flag" in
		w)
			win=true
			((skipCount += 1))
			;;
		c)
			cli=true
			((skipCount += 1))
			;;
		f)
			# TODO may want to deal with flags without getopts
			:
			((skipCount += 1))
			;;
		*)
			echo "Unknown flag: $flag" >&2
			exit 1
			;;
		esac
	done
}

main "$@"
