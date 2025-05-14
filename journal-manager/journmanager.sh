#!/usr/bin/env bash

function spliceGoals {
  local fileName="$1"

  local head=$(cat "$fileName" | head -n9)
  local content=$(cat "$HOME/journal/currentGoals.md")
  local tail=$(cat "$fileName" | tail -n3)
  
  echo "${head}
${content}

${tail}" > "$fileName"
}

function manage {
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

      if [[ ! -e "$fileName" ]]; then
        cp "$HOME/journal/entry-template.md" "$fileName"
      fi

      # TODO, need to figure out how to copy over specific lines, and maybe replace patterns in the template.
      #       Determining the last entry will be interesting, could probably achieve simply with sort and head -n1
      #       find ~/journal/ | grep -E '.*/journal/(january|february|march|april|may|june|july|august|september|october|november|december)\-[0-9]{4}/entry.*' | sort
      
      # NOTE: replace template contents and rewrite to file.
      cat "$fileName" | sed -E "s:\{date\}:$(date '+%m-%d-%Y'):g" > "$fileName"

      # NOTE: splicing in currentGoals
      spliceGoals "$fileName"
      vim "$fileName"
      ;;
    edit)
      if [[ "$date" == "today" ]]; then
        vim "$fileName"
      else
        if [[ -e "$HOME/journal/$date" ]]; then
            vim "$HOME/journal/$date"
        else 
            # TODO should just break out the logic for new and put function call here.
            cp "$HOME/journal/entry-template.md" "$HOME/journal/$date"
            spliceGoals "$HOME/journal/$date"
            vim "$HOME/journal/$date"
        fi
      fi
      ;;
    overwrite)
      # TODO: should probably prompt to confirm overwrite
      # NOTE: replace template contents and rewrite to file.
      cat "$HOME/journal/entry-template.md" > "$fileName"
      cat "$fileName" | sed -E "s:\{date\}:$(date '+%m-%d-%Y'):g" > "$fileName"

      # NOTE: splicing in currentGoals
      spliceGoals "$fileName"
      vim "$fileName"

      ;;
    *)
      echo "Unknown action: $action" >&2
      exit 1
  esac
}

manage $@
