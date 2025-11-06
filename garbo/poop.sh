#!/usr/bin/env bash

if [[ "$1" == '--help' ]]; then
# TODO add config file 
  cat <<EOF
Usage:
  poop command [subcommand...] 

Commands:
  new                   creates a new journal entry in default location ~/journal/{mmm-YYYY} and opens the entry with default \$EDITOR
  edit [subcommand]     opens up journal entry for editing using editor provided by \$EDITOR.

Sub Commands:
  edit:
    today:              shorthand for opening up journal entry at location ~/\$journals/{mmm-YYYY}/entry-YYYYmmdd.md
    {date}:             opens up journal entry for editing using date string parsible via `date` command.
      - e.g.            journmanager edit 2025-01-01
  
EOF
  exit 0
fi

function httpRequestBody {
    echo "http:body = '''#[%dw 2.0
output application/json skipNullOn=\"everywhere\"
---
{}]'''    
"
}

function httpRequestHeaders {
    echo "http:headers = '''#[%dw 2.0
import p from Mule
output application/java
---
{
    client_id: p('system-api.{system}.client_id'),
    client_secret: p('system-api.{system}.client_secret')
}]'''
"
}

function httpRequestQueryParams {
    echo "http:query-params = '''#[%dw 2.0
output application/java
---
{}]'''
"
}

function httpRequestUriParams {
    echo "http:uri-params = '''#[%dw 2.0
output application/java
---
{}]'''
"
}

function httpRequest {
    # TODO need to take all elements from 2 on
    readonly subAction="${@:2}"
    declare -A children

    for item in $subAction; do
        case "$item" in
            body)
                children['body']="$(httpRequestBody)"
                ;;
            queryParams)
                children['queryParams']="$(httpRequestQueryParams)"
                ;;
            uriParams)
                children['uriParams']="$(httpRequestUriParams)"
                ;;
            headers)
                children['headers']="$(httpRequestHeaders)"
                ;;
            *)
                echo "Unsupported operation: $item" >&2
                exit 1
        esac
    done

    echo "http:request(method     = METHOD
             doc:name   = 'NAME'
             config-ref = CONFIG-REF
             path       = PATH
             target     = VARIABLE)
{
    ${children['body']}
    ${children['queryParams']}
    ${children['uriParams']}
    ${children['headers']}
}
"
}

function choiceRouter {
    # TODO fill out
    echo "Not Implemented"
}
function transform {
    # TODO fill out
    echo "Not Implemented"
}
function scatterGather {
    # TODO fill out
    echo "Not Implemented"
}
function jsonLogger {
    # TODO fill out
    echo "Not Implemented"
}
function munit {
    # TODO fill out
    echo "Not Implemented"
}
function main {
    readonly action="$1"

    case "$action" in
        http:request)
            echo "$(httpRequest "$@")"
#            echo "http:request(method     = METHOD
#             doc:name   = 'NAME'
#             config-ref = CONFIG-REF
#             path       = PATH
#             target     = VARIABLE)
#{
#    $(httpRequest "$@") 
#}
#"
            ;;        
        munit)
            ;;
        *)
            echo "Unknown action $action" >&2
            exit 1
    esac
}
main $@
