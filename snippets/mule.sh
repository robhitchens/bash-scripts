#!/usr/bin/env bash
# TODO might be better to structure this with context based help messages.
# TODO could add shorthand for common snippets
# TODO should add tab complete for commands and sub commands. maybe. Or at least a double tap tab to list the possible commands at this state.
# TODO add "install" step to symlink script to mule under /usr/local/bin
# TODO add flags to support dumping out full or minimal attributes for elements.
# TODO might refactor the interface to make it composable by making the last argument to any function a string for the body of the element. This would allow composability utilizing existing bash idioms, but downside will be that composition will require multiple subprocesses which will be slower.
#      or another way would be to accept strings of subcommands for composability and maybe a small syntax to avoid adding multiple quotes. Then if detected could then just pass the arguments through main again without subprocessing. With a generic way of handinling it in place  could refactor higher level components to be a composition rather than hard coded logic
#      would need to figure out solution for emitting nested docs or would need to list all commands in help doc.

# TODO could introduce a flag for declaring a single command and another flag for nesting a secondary command into the first or process the elements inside out to build the output string
# TODO Add support for reading from stdin
# TODO Add support for nesting children and commands using {} syntax, that should work without interference with standard bash commands.
# TODO if adding support for stdin, might as well add a -w flag to allow stdin to be wrapped with another element
# TODO add examples command for snippets of how to use (including examples for reading into stdin)
# TODO add support for reading project local config for attribute defaults.
# TODO add simple support to wrap function to take in array of attributes to find and replace.
# TODO add examples function to poop out docs with executable snippets based on input. Kinda like a separate help doc per command.
# TODO add comment|c using the below snippet example:
# <!-- [STUDIO:":description:"]
# TODO should add shell completion for test command. First arg completion would list out test suites, second completion would list out test flows in the selected test suite
function fullDoc {
	cat <<EOF
Usage:
  mule [OPTS] [COMMANDS...]
  STDIN | mule [OPTS] [COMMAND]

Synopsis:
  mule generates xmq snippets for Mulesoft elements.

Description:
  mule can read commands as args or from stdin (see examples).
  Syntax for commands is white space delimited unless otherwise specified.
  Some commands support repetition at either the root or on specified child elements.
  For example the command flow-ref 2 will produce the following:
    flow-ref(doc:name = ':name-0:'
    name = ':name-0:')
    
    flow-ref(doc:name = ':name-1:'
    name = ':name-1:')


  WIP: commands can be nested within { }. e.g. muleRoot { flow { http:request body headers } transform payload }.
  As shorthand: mr { f { hr b h } tr p }. 
  WIP: attributes can be provided to an element using a bash syntax array. e.g. flow-ref [ doc:name 'Some flow' name a-referenced-flow ]


Options:
  -h|--help                             Prints help doc to stdout
  -w|--wrap                             Wrap flag, wraps content read from stdin with snippet provided as args.
  -v|--verbose                          Verbose flag for test runner
  -t|--timed                            Time flag for test runner
  -l|--loop                             Loop flag to set test runner to until SIGINT (Crtl+C) is sent

Commands:
  help                                  Prints help doc to stdout
  install                               Installs the script. Requires super user permissions.
  test [name [method]]                  Not a snippet, shortcut for running munit test.
  run                                   Not a snippet, shortcut for running application with common configuration.

Commands (Snippets):
  muleRoot|mr                           Generates mule root element
  munitRoot|mur                         Generates munit root element
  comment|c                             Generates a Anypoint studio compatible comment
  comment-multi|cm                      Generates a Anypoint studio compatible multi-line comment
  http:request|hr [children...]         Generates http:request template with the provided valid child element templates.
    children:
        - body|b                        Generates an http:body child element within the parent element.
        - headers|h                     Generants an http:headers child element with a dataweave template within the parent element.
        - queryParams|q                 Generates an http:query-params child element within the parent element.
        - uriParams|u                   Generates an http:uri-params child element within the parent element.
  transform|tr [children...]            Generates ee:template element with the provided child element templates.
    children:
        - payload|p [#]                 Generates the ee:message and ee:set-payload templates with a default dataweave expression within the parent element.
        - variables|v [#]               Generates a ee:variables template with the given (number) of ee:set-variable element templates.
        - attributes|a [#]              Generates the ee:attributes tempalte with the given (number) of ee:set-attribute element templates.
  transform:set-payload|trp             Temporary shortcut for transform payload
  choiceRouter|cr [children...]         Generates a choice template with the provided child element templates.
    children:
        - when|w [#]                    Generates the given (number) of when templates within the parent element.
        - otherwise|o                   Generates a otherwise template within the parent element.
  scatterGather|sg [children...]        Generates a scatter-gather tempalte with the provided child elements.
    children:
        - route|r [#]                   Generates the given (number) of route templates within the parent element.
  jsonLogger|jl                         Generates a jsonlogger template
  log|l                                 Generates a log template
  flow|f [name]                         Generates a flow template with the given flow name
  sub-flow|sf [name]                    Generates a sub-flow template with the given sub-flow name
  flow-ref|fr [name]                    Generates a flow-ref template with the given referenced flow name
  try|t  [children]                     Generates a try scope template
    children:
        - errorhandler|eh               Generates an error-handler template within the parent element
  raise|re                              Generates a raise-error template
  batch:job|b [children]                Generates a batch scope template
    children:
        - process-records|pr [children] Generates a batch:process-records template within the parent element
            - step|s [children]         Generates a batch:step template within the parent element
               - aggregator|a           Generates a batch:aggregator template within the parent element
  munit:config|muc [name]               Generates an munit config template with the given name
  munit:test|mut [children...]          Generates an munit test
    children:
        - execution|e                   Generates an munit:execution template within the parent
        - validate|v                    Generates an munit:validate template within the parent
        - behavior|b                    Generates an munit:behavior template within the parent
  munit:set-event|mus [children...]     Generates an munit:set-event template with valid child elements
    children:
        - payload|p                     Generates an munit:set-payload template within the parent
        - variables|v [#]               Generates an munit:set-variables template with the given number of munit:variable templates within the parent
        - attributes|a [#]              Generates an munit:set-attribute template with the given number of munit:attribute templates within the parent
  munit:assert|mua [type...]            Generates an munit assert template for the given type.
    type:
        - equals|eq [params]            Generates an munit-tools:assert-equals template with the provided params.
        - that|th                       Generatese an munit-tools assert-that template.
  munit:mock|mum [children...]          Generates an muit:mock template with the provided children
    children:
        - when|w                        Generates a munit-tools:mock-when template
        - attribute|a                   Generates a munit-tools:with-attributes template
        - return|r [type]               Generates a munit-tools:then-return template
  munit:verify|muv [children...]        Generates a munit-tools:verify template with the provided children
    children:
        - call|c [#]                    Generates a munit-tools:verify-call template with the given number of munit-tools:verify-call templates  within the parent
        - attributes|a [#]              Generates a munit-tools:with-attributes template with the given number of munit-tools:attribute templates within the parent
  munit:attributes|muat                 Generates a munit-tools:with-attributes template with a single munit-tools:attribute template
  munit:variables|muvar                 Generates a munit-tools:variables template with a single munit-tools:variable template
EOF
}

################################################################################
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
    client_id: p('secure::{api}.{system}.client-id'),
    client_secret: p('secure::{api}.{system}.client-secret')
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

# NOTE: this as a template represents more of a deterministic node, only a definitive subset nodes are allowed and terminate a path.
function httpRequest {
	# FIXME refactor to not subarray, move logic higher up in stack.
	local subActions="${@:2}"
	declare -A children

	for item in $subActions; do
		case "$item" in
		body | b)
			children['body']="$(httpRequestBody)"
			;;
		queryParams | q)
			children['queryParams']="$(httpRequestQueryParams)"
			;;
		uriParams | u)
			children['uriParams']="$(httpRequestUriParams)"
			;;
		headers | h)
			children['headers']="$(httpRequestHeaders)"
			;;
		*)
			echo "Unsupported operation: $item" >&2
			exit 1
			;;
		esac
	done

	echo "http:request(method     = ':method:'
             doc:name   = ':name:'
             doc:id     = $(uuidgen)
             config-ref = ':config-ref:'
             path       = ':path:'
             sendCorrelationId = ALWAYS
             correlationId = #[correlationId]
             target     = ':target:')
{
    ${children['body']}
    ${children['headers']}
    ${children['uriParams']}
    ${children['queryParams']}
}
"
}
################################################################################
function transformPayload {
	local isEmpty="$1"
	if [[ $isEmpty == "0" ]]; then
		echo "ee:message"
	else
		echo "ee:message
{
    ee:set-payload = '''#[%dw 2.0
output application/json
---
{}]'''
}
"
	fi
}
function transformVariables {
	local params="$1"
	if [[ -n "$(echo "$params" | grep -E '[0-9]')" ]]; then
		local instances="$params"
	fi
	if [[ -z $instances ]]; then
		local instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="ee:set-variable(variableName = ':name-$i:') = '''#[%dw 2.0
output application/json
---
{}]'''
"
	done
	echo "ee:variables
{
    $children
}
"
}
# TODO this function may not be needed or even really supported
function transformAttributes {
	local params="$1"
	local instances="0"
	if [[ -n "$(echo "$params" | grep -E '[0-9]')" ]]; then
		instances="$params"
	fi
	if [[ -z $instances ]]; then
		instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="ee:set-attribute(name = ':name-$i:') = '''#[%dw 2.0
output application/json
---
{}]'''
"
	done
	echo "ee:attributes
{
    $children
}
"
}
function transform {
	# FIXME refactor to not subarray, move logic higher up in stack.
	local subActions=(${@:2})
	declare -A children

	local length="${#subActions[@]}"
	for ((i = 0; i < length; i++)); do
		case "${subActions[((i))]}" in
		payload | p)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-1]')" ]]; then
				local instances="${subActions[((i + 1))]}"
				((i = i + 1))
			else
				local instances=1
			fi
			children['payload']="$(transformPayload "$instances")"
			;;
		variables | v)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-9]')" ]]; then
				local instances="${subActions[((i + 1))]}"
				((i = i + 1))
			fi
			children['variables']="$(transformVariables "$instances")"
			;;
		attributes | a)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-9]')" ]]; then
				local instances="${subActions[((i + 1))]}"
				((i = i + 1))
			fi
			children['attributes']="$(transformAttributes "$instances")"
			;;
		esac
	done

	# TODO also include variables and attributes in check, if not null then include message.
	if [[ -z "${children['payload']}" ]]; then
		children['payload']="$(transformPayload 0)"
	fi

	echo "ee:transform(doc:name = 'Transform Message')
{
    ${children['payload']}
    ${children['variables']}
    ${children['attributes']}
}
"
}
################################################################################
function choiceWhen {
	local params="$1"
	if [[ -z "$params" ]]; then
		local instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="when(expression='#[:expression:]')
{
    :children:
}
"
	done
	echo "$children"
}
function choiceOtherwise {
	echo "otherwise {
    :children:
}"
}
function choiceRouter {
	local subActions=(${@:2})
	declare -A children
	local length="${#subActions[@]}"
	for ((i = 0; i < length; i++)); do
		case "${subActions[((i))]}" in
		when | w)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-9]')" ]]; then
				local instances="${subActions[((i + 1))]}"
				((i = i + 1))
			fi
			children['when']="$(choiceWhen "$instances")"
			;;
		otherwise | o)
			children['otherwise']="$(choiceOtherwise)"
			;;
		*)
			echo "Unsupported choice option: ${subActions[((i))]}"
			exit 1
			;;
		esac
	done
	echo "choice(doc:name=':doc:name:')
{
    ${children['when']}
    ${children['otherwise']}
}
"
}
################################################################################
function scatterGatherRoute {
	# Assuming type check has been performed ahead of invocation.
	local params="$1"
	if [[ -z "$params" ]]; then
		params="1"
	fi
	local children=""
	for ((i = 0; i < params; i++)); do
		children+="route {
}
"
	done
	echo "$children"
}
function scatterGather {
	local subActions=(${@:2})
	local length="${#subActions[@]}"
	declare -A children
	for ((i = 0; i < length; i++)); do
		case "${subActions[((i))]}" in
		route | r)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-9]')" ]]; then
				local instances="${subActions[((i + 1))]}"
				((i = i + 1))
			fi
			children['route']="$(scatterGatherRoute "$instances")"
			;;
		*)
			echo "Unsupported action: ${subActions[((i))]}" >&2
			exit 1
			;;
		esac
	done
	echo "scatter-gather(doc:name = Scatter-Gather)
{
    ${children['route']}
}
"
	#       scatter-gather(doc:name = Scatter-Gather
	#                        doc:id   = 0a6cff33-437e-4a9a-b8c0-1aef9072635f)
	#         {
}
################################################################################
function jsonLogger {
	echo "json-logger:logger(doc:name   = ':doc:name:'
        config-ref = JSON_Logger_Config
        message    = ':message:')
"
}
################################################################################
function log {
	echo "logger(level=':level:'
message = ':message:')"
}
################################################################################
# TODO add instance parameter
function flow {
	# TODO may have to refactor if adding support for error-handler
	echo "flow(doc:name = ':name:'
name = ':name:')
{
    :children:
}
"
}
################################################################################
# TODO add instance parameter
# TODO shouldn't be adding logic here for children, should be handling higher up collecting nested children then call process commands on each line
#      and after processes have executed collect as string and find and replace.
#      need to add a pre-process step to look ahead for curly braces.
function subFlow {
	# TODO may have to refactor if adding support for error-handler
	local subActions=(${@:2})
	local root="sub-flow(doc:name = ':doc:name:'
name = ':name:')
{
    :children:
}
"
	# TODO should move logic for processing attributes before and within processCommand logic.
	#for ((i = 0; i < ${#attributes[@]}; i += 2)); do
	#	root="${root/${attributes[i]}/${attributes[((i + 1))]}}"
	#done
	echo "$root"
}
################################################################################
function flowRef {
	# TODO refactor to not handle repeats, create common interface for dealing with repeat element generation + plus attribute replacement
	local subActions=(${@:2})
	#local repeat="1"
	# TODO need to iterate over arguments
	# TODO this should really be an either or, but whatever
	#firstOption="${subActions[0]}"
	#if [[ -n "$(echo "$firstOption" | grep -E '[0-9]')" ]]; then
	#	repeat="$firstOption"
	#fi
	#for ((i = 0; i < repeat; i++)); do
	echo "flow-ref(doc:name = ':doc:name:'
name = ':name:')
"
	#done
}
################################################################################
function tryScope {
	# FIXME refactor to not subarray, move logic higher up in stack.
	local subActions="${@:2}"
	local children=""
	for item in $subActions; do
		case $item in
		errorhandler | eh)
			# TODO figure out to include name for referenced error handler
			children+="error-handler(ref = global-error-handler)"
			;;
		*)
			echo "Unsupported try scope element: $item" >&2
			exit 1
			;;
		esac
	done
	echo "try(doc:name = Try)
{
    :children:
    $children
}
"
}
################################################################################
function raiseError {
	echo "raise-error(doc:name    = 'Raise error'
doc:id      = ':doc:id:'
type        = ':type:'
description = ':description:')"
}
################################################################################
function batchJob {
	# TODO need to figure out if this is actually required anymore
	local subActions=(${@:2})
	# TODO handle children:
	# - process-records | pr
	#   - step | s
	#       - aggregator | a
}
################################################################################
function munitConfig {
	# FIXME: rework to use attributes syntax for replacement
	local name="$2"
	if [[ -z "$name" ]]; then
		name="':name:'"
	fi
	echo "munit:config(name = $name)"
}
function munitTest {
	# FIXME refactor to not subarray, move logic higher up in stack.
	local subActions="${@:2}"
	declare -A children
	for item in $subActions; do
		case $item in
		execution | e)
			# FIXME these need to be reworked. no need for echo
			children['execution']="$(echo 'munit:execution
{
}
')"
			;;
		validation | v)
			children['validation']="$(echo 'munit:validation
{
}
')"
			;;
		behavior | b)
			children['behavior']="$(echo 'munit:behavior
{
}
')"
			;;
		*)
			echo "child element: $item not supported" >&2
			exit 1
			;;
		esac
	done
	echo "munit:test(name = ':name:'
description = ':description:')
{
    ${children['behavior']}
    ${children['execution']}
    ${children['validation']}
}
"
}

function munitSetEventVariables {
	local params="$1"
	if [[ -n "$(echo "$params" | grep -E '[0-9]')" ]]; then
		local instances="$params"
	fi
	if [[ -z $instances ]]; then
		local instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="munit:variable(key = ':key-$i:'
    value = '''#[%dw 2.0
output application/json
---
{}]'''
    mediaType = application/json)
"
	done
	echo "munit:variables
{
    $children
}
"
}

function munitSetEventAttributes {
	local params="$1"
	if [[ -n "$(echo "$params" | grep -E '[0-9]')" ]]; then
		local instances="$params"
	fi
	if [[ -z $instances ]]; then
		local instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="munit:attribute(key = ':key-$i:'
    value = '''#[%dw 2.0
output application/json
---
{}]'''
    mediaType = application/json)
"
	done
	echo "munit:attributes 
{
    $children
}
"
}

function munitSetEvent {
	# FIXME refactor to not subarray, move logic higher up in stack.
	local subActions=(${@:2})
	declare -A children
	local length="${#subActions[@]}"
	for ((i = 0; i < length; i++)); do
		case "${subActions[((i))]}" in
		payload | p)
			children['payload']="munit:payload(value = '''#[%dw 2.0
output application/json
---
{}]'''
mediaType = application/json)
"
			;;
		variables | v)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-9]')" ]]; then
				local instances="${subActions[((i + 1))]}"
				((i = i + 1))
			fi
			children['variables']="$(munitSetEventVariables "$instances")"
			;;
		attributes | a)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-9]')" ]]; then
				local intances="${subActions[((i + 1))]}"
				((i = i + 1))
			fi
			children['attributes']="$(munitSetEventAttributes "$instances")"
			;;
		*)
			echo "Unsupported element: $item" >&2
			exit 1
			;;
		esac
	done
	echo "munit:set-event(doc:name = 'set event')
{
    ${children['payload']}
    ${children['variables']}
    ${children['attributes']}
}
"
}
function munitAssert {
	# FIXME refactor to not subarray, move logic higher up in stack.
	local subActions="${@:2}"
	local children=""
	for item in $subActions; do
		case $item in
		equals | eq)
			children+="munit-tools:assert-equals(doc:name = 'assert equals'
actual = '#[:actual:]'
expected = '#[:expected:]')
"
			;;
		that | th)
			children+="munit-tools:assert-that(doc:name = 'assert that'
expression = #[payload]
is = '#[MunitTools::notNullValue()]'
message = ':message:')
"
			;;
		*)
			echo "Unsupported assert element: $item" >&2
			exit 1
			;;
		esac
	done
	echo "$children"
}
function munitWithAttributes {
	local params="$1"
	if [[ -n "$(echo "$params" | grep -E '[0-9]')" ]]; then
		local instances="$params"
	fi
	if [[ -z $instances ]]; then
		local instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="munit-tools:with-attribute(attributeName = ':attributeName:'
whereValue = ':whereValue-$i:')
"
	done
	echo "
munit-tools:with-attributes {
    ${children}
}
"
}
# FIXME refactor to properly handle arguments
function munitVariables {
	local params="$1"
	if [[ -n "$(echo "$params" | grep -E '[0-9]')" ]]; then
		local instances="$params"
	fi
	if [[ -z $instances ]]; then
		local instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="munit-tools:variable(key = ':key-$i:'
value = '''#[%dw 2.0
           output application/json
           ---
           {}]'''
mediaType = 'application/json')
"
	done
	echo "
munit-tools:variables {
    ${children}
}"
}

function munitVerifyCall {
	local params="$1"
	if [[ -n "$(echo "$params" | grep -E '[0-9]')" ]]; then
		local instances="$params"
	fi
	if [[ -z "$instances" ]]; then
		local instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="munit-tools:verify-call(doc:name = 'Verify Call'
atLeast = ':atLeast:'
atMost = ':atMost:' 
times = ':times:'
processor = ':processor:'
)"
	done
	echo "$children"
}
function munitVerify {
	local subActions=(${@:2})
	local children=""
	local length="${#subActions[@]}"
	#for item in $subActions; do
	for ((i = 0; i < length; i++)); do
		case "${subActions[((i))]}" in
		call | c)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-9]')" ]]; then
				local instances="${subActions[((i + 1))]}"
				((i = i + 1))
			fi
			children+="$(munitVerifyCall "$instances")"
			;;
		attributes | a)
			if [[ -n "$(echo "${subActions[((i + 1))]}" | grep -E '[0-9]')" ]]; then
				local instances="${subActions[((i + 1))]}"
				((i = i + 1))
			fi
			# FIXME should be nested under verify call as child
			children+="{ 
$(munitWithAttributes "$instances")
}"
			;;
		*)
			echo "Unsupported verify element: $item" >&2
			exit 1
			;;
		esac
	done
	echo "$children"
}
function munitMock {
	# TODO keeping implementation simple for now and just allowing generation of sub snippets.
	local subActions="${@:2}"
	local children=""
	for item in $subActions; do
		case $item in
		when | w)
			children+="
munit-tools:mock-when(doc:name = ':doc:name:'
processor = ':processor:')
{
    :children:
}"
			;;
		attribute | a)
			# TODO need to add option for generating multipl or without parent
			children+="
munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
    whereValue = ':whereValue:')
}"
			;;
		return | r)
			# TODO need to handle type.
			# also expand with call to munitVariables
			children+="
munit-tools:then-return {
    munit-tools:payload(value = '''#[:payload:]''')
    munit-tools:variables {
    munit-tools:variable(key = ':key:' 
    value     = '''#[:value:]'''
    mediaType = application/json)
    }
    munit-tools:error(typeId = ':typeId:')
}"
			;;
		*)
			echo "Unsupported mock snippet: $item" >&2
			exit 1
			;;
		esac
	done
	echo "$children"
}
################################################################################
function dataweave {
	echo "%dw 2.0
output application/json
---
{}
"
}
################################################################################
function muleConfigTemplate {
	echo "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd http://www.mulesoft.org/schema/mule/json-logger http://www.mulesoft.org/schema/mule/json-logger/current/mule-json-logger.xsd http://www.mulesoft.org/schema/mule/http http://www.mulesoft.org/schema/mule/http/current/mule-http.xsd http://www.mulesoft.org/schema/mule/ee/core http://www.mulesoft.org/schema/mule/ee/core/current/mule-ee.xsd'
     xmlns:xsi          = http://www.w3.org/2001/XMLSchema-instance
     xmlns:ee           = http://www.mulesoft.org/schema/mule/ee/core
     xmlns:http         = http://www.mulesoft.org/schema/mule/http
     xmlns:json-logger  = http://www.mulesoft.org/schema/mule/json-logger
     xmlns              = http://www.mulesoft.org/schema/mule/core
     xmlns:doc          = http://www.mulesoft.org/schema/mule/documentation)
{
   :children: 
}
"
}
function munitConfigTemplate {
	echo "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd   http://www.mulesoft.org/schema/mule/munit http://www.mulesoft.org/schema/mule/munit/current/mule-munit.xsd   http://www.mulesoft.org/schema/mule/munit-tools  http://www.mulesoft.org/schema/mule/munit-tools/current/mule-munit-tools.xsd'
     xmlns:xsi          = http://www.w3.org/2001/XMLSchema-instance
     xmlns:munit        = http://www.mulesoft.org/schema/mule/munit
     xmlns:munit-tools  = http://www.mulesoft.org/schema/mule/munit-tools
     xmlns              = http://www.mulesoft.org/schema/mule/core
     xmlns:doc          = http://www.mulesoft.org/schema/mule/documentation)
{
    :children:
}
"
}

function studioComment {
	echo "// [STUDIO:\":comment:\"]"
}

function studioCommentMultiline {
	echo "/* [STUDIO:\":comment:\"] :children: [STUDIO] */"
}

function filterTestOutput {
	local display=0
	while IFS=$'\n' read -r line; do
		# TODO probably should use regexes to better forward and backwards compatible with different versions of MULE
		if [[ "$line" == '[INFO] Running MULE_EE with version 4.9.0' ]]; then
			display=1
		fi
		if [[ "$line" == '[INFO] >>> munit:3.3.2:coverage-report (test) > [munit]test @ wsfs-clients-process-api >>>' ]]; then
			display=0
		fi
		if [[ "$line" == '[INFO] BUILD FAILURE' ]]; then
			display=1
		fi
		if ((display == 1)); then
			echo "${line/\[INFO\]/}"
		fi
	done
}

function runMunitTest {
	# NOTE: command assumes that mvn is installed.
	# TODO add additional arguments:
	# * list - list tests recursively with index in src/test/munit
	# * list units file|index - parse xml and list out names of munit tests
	# * watch [files...] [testname] - watch a set of files for change events and run tests. (optional tools to help with that: fswatch, Watchman, inotify-tools)
	local args=(${@:2})
	local command=""
	if [[ -n ${args[0]} ]]; then
		command+="-Dmunit.test=${args[0]}"
	fi
	if [[ -n ${args[1]} ]]; then
		command+="#${args[1]}"
	fi

	local commandString=""
	if [[ -n "$testVerbose" ]]; then
		commandString+="mvn test $command"
	else
		commandString+="mvn test $command | filterTestOutput"
		#commandString+="cat ./snippets/example-test-output.txt | filterTestOutput"
	fi
	if [[ -n "$testTime" ]]; then
		commandString="time ($commandString)"
	fi
	if [[ -n "$testLoop" ]]; then
		commandString="while true; do $commandString; sleep 1; done"
	fi

	echo "running: $commandString"
	eval "$commandString"
}

function run {
	# TODO need to figure out what running the debugger from the command line would be like.
	echo "not yet supported" >&2
	# TODO will probably need to do the following:
	# * set MULE_HOME and MULE_BASE
	# * run ~/tools/AnypointStudio/plugins/org.mule.tooling.server.4.9.ee_7.21.0.202507071837/mule/bin/mule start
	# * provide the properties use in the anypoint configuration.
	exit 1
}

function processCommand {
	local element="$1"
	local content=''
	local length="$#"
	local attributes=()
	local isAttribute=0
	local commands=()
	for ((i = 1; i < length + 1; i++)); do
		if [[ "${!i}" == "[" ]]; then
			isAttribute=1
			continue
			# ideally the remaining arguments passed in are just the context for this component
			# operating on that assumption for now.
		elif [[ "${!i}" == "]" ]]; then
			isAttribute=0
		fi
		if ((isAttribute == 1)); then
			attributes+=("${!i}")
		else
			commands+=("${!i}")
		fi
	done
	if ((isAttribute == 1)); then
		echo "Command '${@:1}' has attributes that are unbalanced. 
Command may be missing ']' to close attributes expression. 
Cannot process further" >&2
		exit 1
	fi
	if ((${#attributes[@]} % 2 != 0)); then
		echo "attributes [${attributes[@]}] with length [${#attributes[@]}] is unbalanced.
Maybe missing key or value?
Cannot process further" >&2
		exit 1
	fi
	case "$element" in
	# TODO use split operation on arguments here before passing to functions.
	# TODO should find way to break out test and run command from this logic, maybe a simple lookahead check in main?
	test)
		runMunitTest ${@:1}
		;;
	run)
		runMule
		;;
	muleRoot | mr)
		# TODO add processing for c flag for child template processing
		content="$(muleConfigTemplate)"
		;;
	munitRoot | mur)
		# TODO add processing for c flag for child template processing
		content="$(munitConfigTemplate)"
		;;
	comment | c)
		content="$(studioComment)"
		;;
	comment-multi | cm)
		content="$(studioCommentMultiline)"
		;;
	http:request | hr)
		content="$(httpRequest "${commands[@]}")"
		;;
	transform | tr)
		content="$(transform "${commands[@]}")"
		;;
	choiceRouter | cr)
		content="$(choiceRouter "${commands[@]}")"
		;;
	scatterGather | sg)
		content="$(scatterGather "${commands[@]}")"
		;;
	jsonLogger | jl)
		content="$(jsonLogger "${commands[@]}")"
		;;
	log | l)
		content="$(log "${commands[@]}")"
		;;
	flow | f)
		content="$(flow "${commands[@]}")"
		;;
	sub-flow | sf)
		content="$(subFlow "${commands[@]}")"
		;;
	flow-ref | fr)
		content="$(flowRef "${commands[@]}")"
		;;
	try | t)
		content="$(tryScope "${commands[@]}")"
		;;
	raise-error | re)
		content="$(raiseError "${commands[@]}")"
		;;
	batch:job | b)
		content="$(batchJob "${commands[@]}")"
		;;
	munit:config | muc)
		content="$(munitConfig "${commands[@]}")"
		;;
	munit:test | mut)
		content="$(munitTest "${commands[@]}")"
		;;
	munit:set-event | mus)
		content="$(munitSetEvent "${commands[@]}")"
		;;
	munit:assert | mua)
		content="$(munitAssert "${commands[@]}")"
		;;
	munit:verify | muv)
		content="$(munitVerify "${commands[@]}")"
		;;
	munit:attributes | muat)
		# TODO roll up into munit:verify
		content="$(munitWithAttributes)"
		;;
	munit:variables | muvar)
		# TODO roll up into munit:verify
		content="$(munitVariables "${commands[@]}")"
		;;
	munit:mock | mum)
		content="$(munitMock "${commands[@]}")"
		;;
	dataweave | dw)
		dataweave
		;;
	*)
		echo "Unknown element: $element" >&2
		exit 1
		;;
	esac
	# TODO process attributes in content here.
	# TODO reassignment may not be necessary or efficient
	if ((${#attributes[@]} != 0)); then
		for ((i = 0; i < ${#attributes[@]}; i += 2)); do
			content="${content/\'${attributes[i]}\'/${attributes[((i + 1))]}}"
		done
	fi
	echo "$content"
}

function installScript {
	# TODO should add flag to shorthand install
	# TODO should add flag for uninstall, instead of confusing behavior
	local symlink='/usr/local/bin/mule'
	local symlink_short='/usr/local/bin/ml'
	# TODO should probably prompt user before nuking existing symlink file.
	if [[ -f $symlink || -f $symlink_short ]]; then
		echo "Removing existing links: $symlink, $symlink_short" >&2
		rm -f $symlink $symlink_short
	else
		local scriptLocation=$(find . -type f -iname 'mule.sh' | xargs realpath --relative-to=/ | sed -E 's/(.*)/\/\1/')
		# TODO should error out if script can't be found.
		echo "Adding symlink: $symlink"
		ln -s $scriptLocation $symlink
		echo "Adding symlink: $symlink_short"
		ln -s $scriptLocation $symlink_short
	fi
	# assuming a first time use it would be executed where the script is located.
	# should also check to see if the symlink already exists.
	# TODO not sure if starting point for find should be the current directory or start at root
	# TODO could attempt to find locally first before jumping up to root.
}

function main {
	# is args 'help' sub command?
	if [[ "$1" == '--help' || "$1" == 'help' ]]; then
		fullDoc
		exit 0
	fi
	# is first argument empty and input connected to terminal?
	if [[ "$1" == '' && -t 0 ]]; then
		fullDoc
		exit 0
	fi
	# TODO should probably add an uninstall command, should remove symlink and config (or at least prompt user what they want to delete?)
	# TODO should probably add a config command as well.
	if [[ "$1" == 'install' ]]; then
		installScript
		exit 0
	fi

	local skipCount=0
	while getopts "wvlth" flag; do
		case "$flag" in
		w)
			wrap=true
			((skipCount += 1))
			;;
		v)
			testVerbose=true
			((skipCount += 1))
			;;
		l)
			testLoop=true
			((skipCount += 1))
			;;
		t)
			testTime=true
			((skipCount += 1))
			;;
		h)
			fullDoc
			exit 0
			;;
		*)
			echo "Unknown flag: $flag" >&2
			exit 1
			;;
		esac
	done
	# FIXME refactor logic to parse commands
	if [[ "$1" == 'test' ]]; then
		runMunitTest "${@:1}"
		exit 0
	fi
	# FIXME need to deal with mixed arguments+pipe for expression replacement in existing document and/or wrap stdin with argument
	local argLength="$#"
	# FIXME add support for simple find and replace of attributes, might be separate flag.
	# TODO may need to utilize this when processing nested children. Would need to write bash string to be evaled as a series of wrap calls.
	if [[ -n "$wrap" ]]; then
		# FIXME need to appropriately remove -w|--wrap option from arguments.
		local template=$(processCommand "${@:2}")
		local content=''
		while read -r line; do
			# FIXME kinda of a hack, need to be able to evaluate newlines in string replacement
			content+="$line
"
		done
		echo "${template/:children:/$content}"
	elif ((argLength > 0)); then
		# FIXME encapsulating input as array causes problems with whitespace in attribute replacement
		# TODO filter out attributes for replacement here.
		#local input=($@)
		# TODO this works for preserving whitespace (even to process command), but would need to propagate to all functions,
		# better to just abstract higher up in the call chain before template processing.
		local input=()
		for ((i = 1; i < argLength + 1; i++)); do
			input+=("${!i}")
		done
		# TODO need to remember why I chose to use the input length here instead of len of $input
		local inputLen="$#"
		if ((skipCount == 0)); then
			processCommand "${input[@]}"
		else
			processCommand "${input[@]:((skipCount)):((inputLen - skipCount))}"
		fi
		# is process connected to pipe/redirected input?
	elif [[ ! -t 0 ]]; then
		# FIXME rework to preprocess for curly braces and batch up runs of processCommand
		# FIXME add logic wrapping processCommand with the read loop, will be easier to control advancing the loop and adding recursion.
		#       will have to see how this affects performance, but the use case is for pretty much evaluating a more complex template in line.
		while read -r line; do
			processCommand $line
		done
	fi
}
main "$@"
