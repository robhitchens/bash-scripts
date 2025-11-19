#!/usr/bin/env bash
# TODO might be better to structure this with context based help messages.
# TODO could add a function to handle routing of common flows, for simple embedding child elements
# TODO could add shorthand for common snippets
# TODO should add tab complete for commands and sub commands. maybe. Or at least a double tap tab to list the possible commands at this state.
# TODO could template things and add a separator to help make things more composable.
# TODO add "install" step to symlink script to mule under /usr/local/bin
# TODO add flags to support dumping out full or minimal attributes for elements.
# TODO can utilize 'shift [n]' to deal with arguments that take parameters
# TODO might refactor the interface to make it composable by making the last argument to any function a string for the body of the element. This would allow composability utilizing existing bash idioms, but downside will be that composition will require multiple subprocesses which will be slower.
#      or another way would be to accept strings of subcommands for composability and maybe a small syntax to avoid adding multiple quotes. Then if detected could then just pass the arguments through main again without subprocessing. With a generic way of handinling it in place  could refactor higher level components to be a composition rather than hard coded logic
#      would need to figure out solution for emitting nested docs or would need to list all commands in help doc.

# TODO could introduce a flag for declaring a single command and another flag for nesting a secondary command into the first or process the elements inside out to build the output string
if [[ "$1" == '--help' || "$1" == 'help' || -z "$1" ]]; then
	# FIXME update help doc
	cat <<EOF
Usage:
  mule [--help | help | parent [children...]] 

Description:
  mule generates xmq snippets for Mulesoft elements

Commands:
  --help|help                           Prints help doc to stdout
  test [name [method]]                  Not a snippet, shortcut for running munit test.
  run                                   Not a snippet, shortcut for running application with common configuration.
  muleTemplate|mtmpl                    Generates mule root element
  munitTemplate|mutmpl                  Generates munit root element
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
  choiceRouter|cr [children...]         WIP: Generates a choice template with the provided child element templates.
    children:
        - when|w [#]                    WIP: Generates the given (number) of when templates within the parent element.
        - otherwise|o                   WIP: Generates a otherwise template within the parent element.
  scatterGather|sg [children...]        WIP: Generates a scatter-gather tempalte with the provided child elements.
    children:
        - route|r [#]                   WIP: Generates the given (number) of route templates within the parent element.
  jsonLogger|jl [children...]           WIP: Generates a jsonlogger template with the provided children.
    children:
  log|l                                 WIP: Generates a log template
  flow|f [name]                         Generates a flow template with the given flow name
  sub-flow|sf [name]                    Generates a sub-flow template with the given sub-flow name
  flow-ref|fr [#] [name]                Generates a flow-ref template with the given referenced flow name
  try|t  [children]                     Generates a try scope template
    children:
        - errorhandler|eh               Generates an error-handler template within the parent element
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
        - call|c                        Generates a munit-tools:verify-call template within the parent
        - attributes|a [#]              WIP: Generates a munit-tools:with-attributes template with the given number of munit-tools:attribute templates within the parent.
  munit:attributes|muat                 Generates a munit-tools:with-attributes template with a single munit-tools:attribute template
  munit:variables|muvar                 Generates a munit-tools:variables template with a single munit-tools:variable template
EOF
	exit 0
fi

# if [[ "$1" == "--help-short" ]]; then
# fi

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

function httpRequest {
	# FIXME refactor to not subarray, move logic higher up in stack.
	readonly subActions="${@:2}"
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

	echo "http:request(method     = '{method}'
             doc:name   = '{name}'
             doc:id     = $(uuidgen)
             config-ref = '{config-ref}'
             path       = '{path}'
             sendCorrelationId = ALWAYS
             correlationId = #[correlationId]
             target     = '{target}')
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
		children+="ee:set-variable(variableName = '{name-$i}') = '''#[%dw 2.0
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
		children+="ee:set-attribute(name = '{name-$i}') = '''#[%dw 2.0
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
	readonly subActions=(${@:2})
	declare -A children
	# FIXME this loop needs to have knowledge of the index it's looking at

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
function choiceRouter {
	# TODO fill out
	echo "Not Implemented"
}
################################################################################
function scatterGather {
	# TODO fill out
	echo "Not Implemented"
}
################################################################################
function jsonLogger {
	# TODO fill out
	echo "Not Implemented"
}
################################################################################
function log {
	# TODO fill out
	echo "Not Implemented"
}
################################################################################
function flow {
	# TODO may have to refactor if adding support for error-handler
	local name="$2"
	if [[ -n "$name" ]]; then
		name="'{name}'"
	fi
	echo "flow(doc:name = $name
name = $name)
{
}
"
}
################################################################################
function subFlow {
	local name="$2"
	if [[ -n "$name" ]]; then
		name="'{name}'"
	fi
	echo "sub-flow(doc:name = $name
name = $name)
{
}
"
}
################################################################################
function flowRef {
	local subActions=(${@:2})
	local repeat="1"
	local name=""
	#TODO this should really be an either or, but whatever
	if ((${#subActions[@]} == 2)); then
		repeat="${subActions[0]}"
		name="${subActions[1]}"
	else
		firstOption="${subActions[0]}"
		if [[ -n "$(echo "$firstOption" | grep -E '[0-9]')" ]]; then
			repeat="$firstOption"
			name="placeholder"
		elif [[ -z "$name" || "$name" -eq '' ]]; then
			name="placeholder"
		fi
	fi
	for ((i = 0; i < repeat; i++)); do
		echo "flow-ref(doc:name = '{$name-$i}'
name = '{$name-$i}')
"
	done
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
    $children
}
"
}
################################################################################
function munitConfig {
	local name="$2"
	if [[ -z "$name" ]]; then
		name="'{name}'"
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
	echo "munit:test(name = '{name}'
description = '{description}')
{
    ${children['behavior']}
    ${children['execution']}
    ${children['validation']}
}
"
}

function munitSetEvent {
	# FIXME refactor to not subarray, move logic higher up in stack.
	local subActions="${@:2}"
	declare -A children
	for item in $subActions; do
		# FIXME: elements may not be 100% accurate and will probably need to be refactored.
		case $item in
		payload | p)
			children['payload']="munit:payload(value = '''#[%dw 2.0
output application/json
---
{}]'''
mediaType = application/json)
"
			;;
		variables | v)
			# TODO figure out how to deal with subAction parameters
			children['variables']="munit:variables {
    munit:variable(key = '{key}'
    value = '''#[%dw 2.0
output application/json
---
{}]'''
    mediaType = application/json)
}
"
			;;
		attributes | a)
			# TODO figure out how to deal with subAction parameters
			children['attributes']="munit:attributes {
    munit:attribute(key = '{key}'
    value = '''#[%dw 2.0
output application/json
---
{}]'''
    mediaType = application/json)
}
"
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
actual = '#[{actual}]'
expected = '#[{true}]')
"
			;;
		that | th)
			children+="munit-tools:assert-that(doc:name = 'assert that'
expression = #[payload]
is = '#[MunitTools::notNullValue()]'
message = '{message}')
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
function munitVerify {
	local subActions="${@:2}"
	local children=""
	for item in $subActions; do
		case $item in
		call | c)
			children+="
munit-tools:verify-call(doc:name = 'Verify Call'
atLeast = 0
atMost = 1
times = 1
processor = '{processor}'
)"
			;;
		attributes | a)
			echo "attributes not yet supported" >&2
			exit 1
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
	# TODO expand with expressions to repeat number of attributes.
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
		children+="munit-tools:with-attribute(attributeName = '{attributeName}'
whereValue = '{whereValue-$i}')
"
	done
	echo "
munit-tools:with-attributes {
    ${children}
}
"
}
function munitVariables {
	# TODO expane with expressions to repeat number of variables.
	local params="$1"
	if [[ -n "$(echo "$params" | grep -E '[0-9]')" ]]; then
		local instances="$params"
	fi
	if [[ -z $instances ]]; then
		local instances="1"
	fi
	local children=""
	for ((i = 0; i < instances; i++)); do
		children+="munit-tools:variable(key = '{key}'
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
function munitMock {
	# TODO implement
	# TODO keeping implementation simple for now and just allowing generation of sub snippets.
	local subActions="${@:2}"
	local children=""
	for item in $subActions; do
		case $item in
		when | w)
			children+="
munit-tools:mock-when(doc:name = '{doc:name}'
processor = '{processor}')
{

}"
			;;
		attribute | a)
			# TODO need to add option for generating multipl or without parent
			children+="
munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = '{attributeName}'
    whereValue = '{whereValue}')
}"
			;;
		return | r)
			# TODO need to handle type.
			children+="
munit-tools:then-return {
    munit-tools:payload(value = '''#[{}]''')
    munit-tools:variables {
    munit-tools:variable(key = '{key}' 
    value     = '''#[true]'''
    mediaType = application/json)
    }
    munit-tools:error(typeId = '{typeId}')
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
function muleConfigTemplate {
	echo "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd http://www.mulesoft.org/schema/mule/json-logger http://www.mulesoft.org/schema/mule/json-logger/current/mule-json-logger.xsd http://www.mulesoft.org/schema/mule/http http://www.mulesoft.org/schema/mule/http/current/mule-http.xsd http://www.mulesoft.org/schema/mule/ee/core http://www.mulesoft.org/schema/mule/ee/core/current/mule-ee.xsd'
     xmlns:xsi          = http://www.w3.org/2001/XMLSchema-instance
     xmlns:ee           = http://www.mulesoft.org/schema/mule/ee/core
     xmlns:http         = http://www.mulesoft.org/schema/mule/http
     xmlns:json-logger  = http://www.mulesoft.org/schema/mule/json-logger
     xmlns              = http://www.mulesoft.org/schema/mule/core
     xmlns:doc          = http://www.mulesoft.org/schema/mule/documentation)
{
}
"
}
function munitConfigTemplate {
	echo "mule(xsi:schemaLocation = '   http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd   http://www.mulesoft.org/schema/mule/munit http://www.mulesoft.org/schema/mule/munit/current/mule-munit.xsd   http://www.mulesoft.org/schema/mule/munit-tools  http://www.mulesoft.org/schema/mule/munit-tools/current/mule-munit-tools.xsd'
     xmlns:xsi          = http://www.w3.org/2001/XMLSchema-instance
     xmlns:munit        = http://www.mulesoft.org/schema/mule/munit
     xmlns:munit-tools  = http://www.mulesoft.org/schema/mule/munit-tools
     xmlns              = http://www.mulesoft.org/schema/mule/core
     xmlns:doc          = http://www.mulesoft.org/schema/mule/documentation)
{
}
"
}

function runMunitTest {
	local args=(${@:2})
	local command=""
	if [[ -n ${args[0]} ]]; then
		command+="-Dmunit.test=${args[0]}"
	fi
	if [[ -n ${args[1]} ]]; then
		command+="#${args[1]}"
	fi
	echo "running: mvn test $command"
	mvn test $command
}

function run {
	echo "not yet supported" >&2
	# TODO will probably need to do the following:
	# * set MULE_HOME and MULE_BASE
	# * run ~/tools/AnypointStudio/plugins/org.mule.tooling.server.4.9.ee_7.21.0.202507071837/mule/bin/mule start
	# * provide the properties use in the anypoint configuration.
	exit 1
}

function main {
	readonly element="$1"

	case "$element" in
	# TODO use split operation on arguments here before passing to functions.
	test)
		runMunitTest $@
		;;
	run)
		runMule
		;;
	muleTemplate | mtmpl)
		muleConfigTemplate
		;;
	munitTemplate | mutmpl)
		munitConfigTemplate
		;;
	http:request | hr)
		httpRequest "$@"
		;;
	transform | tr)
		transform "$@"
		;;
	# FIXME: temporary shortcut
	transform:set-payload | trp)
		transformPayload 0
		;;
	choiceRouter | cr)
		choiceRouter "$@"
		;;
	scatterGather | sg)
		scatterGather "$@"
		;;
	jsonLogger | jl)
		jsonLogger "$@"
		;;
	log | l)
		log "$@"
		;;
	flow | f)
		flow "$@"
		;;
	sub-flow | sf)
		subFlow "$@"
		;;
	flow-ref | fr)
		flowRef "$@"
		;;
	try | t)
		tryScope "$@"
		;;
	munit:config | muc)
		munitConfig "$@"
		;;
	munit:test | mut)
		munitTest "$@"
		;;
	munit:set-event | mus)
		munitSetEvent "$@"
		;;
	munit:assert | mua)
		munitAssert "$@"
		;;
	munit:verify | muv)
		munitVerify "$@"
		;;
	munit:attributes | muat)
		munitWithAttributes
		;;
	munit:variables | muvar)
		munitVariables
		;;
	munit:mock | mum)
		munitMock "$@"
		;;
	*)
		echo "Unknown element: $element" >&2
		exit 1
		;;
	esac
}
main "$@"
