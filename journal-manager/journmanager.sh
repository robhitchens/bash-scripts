#!/usr/bin/env bash

if [[ "$1" == '--help' ]]; then
	# TODO add config file
	cat <<EOF
Usage:
  journmanager command [subcommand] 

Commands:
  install               symlinks script to /usr/bin/local/journal
  new                   creates a new journal entry in default location ~/journal/{mmm-YYYY} and opens the entry with default \$EDITOR
  edit [subcommand]     opens up journal entry for editing using editor provided by \$EDITOR.

Sub Commands:
  edit:
    today:              shorthand for opening up journal entry at location ~/\$journals/{mmm-YYYY}/entry-YYYYmmdd.md
    {date}:             opens up journal entry for editing using date string parsible via $(date) command.
      - e.g.            journmanager edit 2025-01-01
  
EOF
	exit 0
fi

# TODO should add generic templating logic using awk or something and then make that configurable.
function spliceGoals {
	local fileName="$1"

	# TODO refactor to use awk to replace the {goals} section in the header
	local head=$(cat "$fileName" | head -n9)
	local content=$(cat "$HOME/journal/currentGoals.md")
	local tail=$(cat "$fileName" | tail -n3)

	echo "${head}
${content}

${tail}" >"$fileName"
}

# TODO could add option to configuration to add encryption and decryption provided by user keys.
# TODO add action edit goals, as a shortcut to editing the currentGoals template.
# TODO add action archive and setup config for archive location. archive action could accept an additional argument to specify which folder or entry to archive.
# TODO add support for config file for locations of journal and templates
# TODO could action 'view' with options to view individual entry or concatenate entries into a view
# TODO could add action for archiving months of entries.
# TODO could add action 'search' to run simple grep commands against journal entries + archives.
function manage {
	# TODO could update logic with different types of journal templates and logic.
	# E.g. could add functionality to start new idea journal entries with fuzzy matching for entries.
	local action=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	local date="$2"

	local directory=$(date '+%B-%Y' | tr '[:upper:]' '[:lower:]')
	local fileName="$HOME/journal/$directory/entry-$(date '+%Y%m%d').md"

	case "$action" in
	# TODO should add option to new to create new files for different days. default to today.
	new)
		if [[ ! -e "$HOME/journal/$directory" ]]; then
			mkdir -p "$HOME/journal/$directory"
		fi

		if [[ -e "$fileName" ]]; then
			echo "Entry already exists for [$fileName]
auto running: journal edit today" >&2
			sleep 2
			bash $0 edit today
			return -1
		else
			cp "$HOME/journal/entry-template.md" "$fileName"
		fi

		# TODO, need to figure out how to copy over specific lines, and maybe replace patterns in the template.
		#       Determining the last entry will be interesting, could probably achieve simply with sort and head -n1
		#       find ~/journal/ | grep -E '.*/journal/(january|february|march|april|may|june|july|august|september|october|november|december)\-[0-9]{4}/entry.*' | sort

		# NOTE: replace template contents and rewrite to file.
		# TODO: could simplify logic by using awk to perform replacement
		cat "$fileName" | sed -E "s:\{date\}:$(date '+%m-%d-%Y'):g" >"$fileName"

		# NOTE: splicing in currentGoals
		spliceGoals "$fileName"
		vim "$fileName"
		;;
	edit)
		if [[ "$date" == "today" ]]; then
			vim "$fileName"
		elif [[ "$date" == '' ]]; then
			echo "value for \$date not provided assuming default of today" >&2
			sleep 2
			vim "$fileName"
		else
			local parentDir=$(date --date="$date" +"%B-%Y" | tr '[:upper:]' '[:lower:]')
			local parsedDate="entry-$(date --date="$date" +'%Y%m%d').md"
			if [[ -e "$HOME/journal/$parentDir/$parsedDate" ]]; then
				vim "$HOME/journal/$parentDir/$parsedDate"
			else
				# FIXME: should just break out the logic for new and put function call here.
				cp "$HOME/journal/entry-template.md" "$HOME/journal/$date"
				spliceGoals "$HOME/journal/$date"
				vim "$HOME/journal/$date"
			fi
		fi
		;;
	overwrite)
		# TODO: should probably prompt to confirm overwrite
		# NOTE: replace template contents and rewrite to file.
		cat "$HOME/journal/entry-template.md" >"$fileName"
		cat "$fileName" | sed -E "s:\{date\}:$(date '+%m-%d-%Y'):g" >"$fileName"

		# NOTE: splicing in currentGoals
		spliceGoals "$fileName"
		vim "$fileName"

		;;
	*)
		echo "Unknown action: $action" >&2
		exit 1
		;;
	esac
}

function installScript {
	local symlink='/usr/local/bin/journal'
	# TODO should probably prompt user before nuking existing symlink file.
	if [[ -f $symlink ]]; then
		echo "link [$symlink] already exists. Removing..."
		rm -f $symlink
	fi

	local scriptLocation=$(find . -type f -iname 'journmanager.sh' | xargs realpath --relative-to=/ | sed -E 's/(.*)/\/\1/')

	# TODO should error out if script can't be found.
	echo "linking $scriptLocation -> $symlink"
	ln -s $scriptLocation $symlink
}

if [[ "$1" == 'install' ]]; then
	installScript
else
	manage $@
fi
