#!/usr/bin/env bash
# TODO will probably have to symlink this into /usr/local/share to be able to use in vim.
# TODO might be better to structure this with context based help messages.
# TODO could add a function to handle routing of common flows, for simple embedding child elements

if [[ "$1" == '--help' || -z "$1" ]]; then
# FIXME update help doc
  cat <<EOF
Usage:
  poop parent [children...] 

Description:
  poop generates xmq snippets for Mulesoft elements

Commands:
  muleTemplate                      Generates mule root element
  munitTemplate                     Generates munit root element
  http:request [children...]        Generates http:request template with the provided valid child element templates.
    children:
        - body                      Generates an http:body child element within the parent element.
        - queryParams               Generates an http:query-params child element within the parent element.
        - uriParams                 Generates an http:uri-params child element within the parent element.
        - headers                   Generants an http:headers child element with a dataweave template within the parent element.
  transform [children...]           WIP: Generates ee:template element with the provided child element templates.
    children:
        - payload                   Generates the ee:message and ee:set-payload templates with a default dataweave expression within the parent element.
        - variables [#]             Generates a ee:variables template with the given (number) of ee:set-variable element templates.
        - attributes [#]            Generates the ee:attributes tempalte with the given (number) of ee:set-attribute element templates.
  choiceRouter [children...]        WIP: Generates a choice template with the provided child element templates.
    children:
        - when [#]                  WIP: Generates the given (number) of when templates within the parent element.
        - otherwise                 WIP: Generates a otherwise template within the parent element.
  scatterGather [children...]       WIP: Generates a scatter-gather tempalte with the provided child elements.
    children:
        - route [#]                 WIP: Generates the given (number) of route templates within the parent element.
  jsonLoger [children...]           WIP: Generates a jsonlogger template with the provided children.
    children:
  log                               WIP: Generates a log template
  flow [name]                       WIP: Generates a flow template with the given flow name
  sub-flow [name]                   WIP: Generates a sub-flow template with the given sub-flow name
  flow-ref [name]                   WIP: Generates a flow-ref template with the given referenced flow name
  try                               WIP: Generates a try scope
  munit:config [name]               WIP: Generates an munit config template with the given name
  munit:test [children...]          WIP: Generates an munit test
    children:
        - execution                 WIP: Generates an munit:execution template within the parent
        - validate                  WIP: Generates an munit:validate template within the parent
        - mock                      WIP: Generates an munit:mock template within the parent
  munit:set-event [children...]     WIP: Generates an munit:set-event template with valid child elements
    children:
        - payload                   WIP: Generates an munit:set-payload template within the parent
        - variables [#]             WIP: Generates an munit:set-variables template with the given number of munit:variable templates within the parent
        - attributes [#]            WIP: Generates an munit:set-attribute template with the given number of munit:attribute templates within the parent
  munit:assert [type...]            WIP: Generates an munit assert template for the given type.
    type:
        - equals [params]           WIP: Generates an munit-tools:assert-equals template with the provided params.
  munit:mock [children...]          WIP: Generates an muit:mock template with the provided children
    children:
        - when                      WIP: Generates a munit-tools:mock-when template
        - attribute                 WIP: Generates a munit-tools:with-attributes template
        - return [type]             WIP: Generates a munit-tools:then-return template
EOF
  exit 0
fi

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
    readonly subActions="${@:2}"
    declare -A children

    for item in $subActions; do
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
################################################################################
function transformPayload {
    local isEmpty="$1"
    if [[ $isEmpty == "1" ]]; then
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
    local instances="$1"
    if [[ -z $instances ]]; then
        instances=1
    else
        instances=$(("$instances"))
    fi
    local children=""
    for ((i=0; i < $instances; i++)); do
        children+="ee:set-variable(variableName=NAME) = '''#[%dw 2.0
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
    local instances="$1"
    if [[ -z $instances ]]; then
        instances=1
    else
        instances=$(("$instances"))
    fi
    local children=""
    for ((i=0; i < $instances; i++)); do
        children+="ee:set-attribute(name=NAME) = '''#[%dw 2.0
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
    readonly subActions="${@:2}"
    declare -A children
    for item in $subActions; do
        case "$item" in
            payload)
                children['payload']="$(transformPayload 1)"
                ;;
            variables)
                # TODO advance pointer and pass count variable if present.
                # TODO may just be simpler to include = 3 instead of worrying about advancing
                children['variables']="$(transformVariables)"
                ;;
            attributes)
                # TODO advance pointer and pass count variable if present.
                # TODO may just be simpler to include = 3 instead of worrying about advancing
                children['attributes']="$(transformAttributes)"
        esac
    done
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
        name="NAME"
    fi
    echo "flow(doc:name = '$name'
name = $name)
{
}
"
}
################################################################################
function subFlow {
    local name="$2"
    if [[ -n "$name" ]]; then
        name="NAME"
    fi
    echo "sub-flow(doc:name = '$name'
name = $name)
{
}
"
}
################################################################################
function flowRef {
    local name="$2"
    if [[ -n "$name" ]]; then
        name="NAME"
    fi
    echo "flow-ref(doc:name = '$name'
name = $name)
"
}
################################################################################
function tryScope {
    local subActions="${@:2}"
    local children=""
    for item in subActions; do
        case $item in
            errorhandler)
                # TODO figure out to include name for referenced error handler
                children+="error-handler(ref = global-error-handler)"
                ;;
            *)
                echo "Unsupported try scope element: $item" >&2
                exit 1
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
        name="NAME"
    fi
    echo "munit:config(name = $name)"
}
function munitTest {
    local subActions="${@:2}"
    declare -A children
    for item in $subActions; do
        case $item in
            execution)
                children['execution']="$(echo 'munit:execution
{
}
')"
                ;;
            validation)
                children['validation']="$(echo 'munit:validation
{
}
')"
                ;;
            behavior)
                children['behavior']="$(echo 'munit:behavior
{
}
')"
                ;;
            *)
                echo "child element: $item not supported" >&2
                exit 1
        esac
    done
    echo "munit:test(name = 'test-name'
description = 'test description')
{
    ${children['behavior']}
    ${children['execution']}
    ${children['validation']}
}
"
}

function munitSetEvent {
#            munit:set-event(doc:name = 'Set applCde to "CIB"'
# 15                             doc:id   = f9144504-540b-4203-94b5-8137615d4f5b)                                                                                                             16             {
# 17                 munit:variables {
# 18                     munit:variable(key       = dynamicProfile
# 19                                    value     = '{"Entity": {"customersDynamicProfile": {"applCde": "CIB"}}}'
# 20                                    mediaType = application/json)                                                                                                                         21                 }
# 22             }
    local subActions="${@:2}"
    declare -A children
    for item in $subActions; do
        # FIXME: elements may not be 100% accurate and will probably need to be refactored.
        case $item in
            payload)
                children['payload']="munit:payload(value = '{}'
mediaType = application/json)
"
                ;;
            variables)
                # TODO figure out how to deal with subAction parameters
                children['variables']="munit:variables {
    munit:variable(key = KEY
    value = '{}'
    mediaType = application/json)
}
"
                ;;
            attributes)
                # TODO figure out how to deal with subAction parameters
                children['attributes']="munit:attributes {
    munit:attribute(key = KEY
    value = '{}'
    mediaType = application/json)
}
"
                ;;
            *)
                echo "Unsupported element: $item" >&2
                exit 1
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
    local subActions="${@:2}"
    local children=""
    for item in $subActions; do
        case $item in 
            equals)
#                munit-tools:assert-equals(doc:name = 'enrolledInOnlineBanking is true'
# 29                                       doc:id   = 7a598903-c79f-4453-abce-3f3248daf920
# 30                                       actual   = #[vars.enrolledInOnlineBanking]
# 31                                       expected = #[true])
                children+="munit-tools:assert-equals(doc:name = 'assert equals'
actual = #[true]
expected = #[true])
"
                ;;
            *)
                echo "Unsupported assert element: $item" >&2
                exit 1
        esac
    done
    echo "$children"
}
function munitMock {
    # TODO implement
    # TODO keeping implementation simple for now and just allowing generation of sub snippets.
    local subActions="${@:2}"
    local children=""
    for item in $subActions; do
        case $item in
            when)
                children+="munit-tools:mock-when(doc:name = 'doc name'
processor = 'processor')
{

}
"
                ;;
            attribute)
                # TODO need to add option for generating multipl or without parent
                children+="munit-tools:with-attributes {
munit-tools:with-attribute(attributeName = name
whereValue = value)
}"
                ;;
            return)
                # TODO need to handle type.
                children+="munit-tools:then-return {
munit-tools:payload(value = '''#[{}]''')
munit-tools:variables {
munit-tools:variable(key = name
value     = '''#[true]'''
mediaType = application/json)
}
munit-tools:error(typeId = id)
}"
                ;;
            *)
                echo "Unsupported mock snippet: $item" >&2
                exit 1
        esac
    done
    echo "$children"
    # <munit-tools:payload/>
#    <munit:behavior >
#			<munit-tools:mock-when doc:name="Request One; Return 500" doc:id="d3a9c658-e3ff-4a67-8cb2-494556e4744d" processor="http:request">
#				<munit-tools:with-attributes >
#					<munit-tools:with-attribute whereValue="c2304ce6-7bd3-4678-ba85-19a365750727" attributeName="doc:id" />
#				</munit-tools:with-attributes>
#				<munit-tools:then-return >
#					<munit-tools:error typeId="HTTP:INTERNAL_SERVER_ERROR" />
#				</munit-tools:then-return>
#			</munit-tools:mock-when>
#			<munit-tools:mock-when doc:name="Request Two; Return 404" doc:id="91068ed8-eec7-4b6a-be03-805317b66d91" processor="http:request" >
#				<munit-tools:with-attributes >
#					<munit-tools:with-attribute whereValue="cef94f38-b1e1-4c94-872f-c5ec9364851f" attributeName="doc:id" />
#				</munit-tools:with-attributes>
#				<munit-tools:then-return >
#					<munit-tools:error typeId="HTTP:NOT_FOUND" />
#				</munit-tools:then-return>
#			</munit-tools:mock-when>
#			<munit-tools:mock-when doc:name="Request Three; Return 400" doc:id="3075764b-0255-4dab-b35e-28c2ff79e22b" processor="http:request" >
#				<munit-tools:with-attributes >
#					<munit-tools:with-attribute whereValue="c1523003-d284-429e-b6c3-88fbbe5bf5a3" attributeName="doc:id" />
#				</munit-tools:with-attributes>
#				<munit-tools:then-return >
#					<munit-tools:error typeId="HTTP:BAD_REQUEST" />
#				</munit-tools:then-return>
#			</munit-tools:mock-when>
#		</munit:behavior>
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
function main {
    readonly element="$1"

    case "$element" in
        # TODO use split operation on arguments here before passing to functions.
        muleTemplate)
            echo "$(muleConfigTemplate)"
            ;;
        munitTemplate)
            echo "$(munitConfigTemplate)"
            ;;
        http:request)
            echo "$(httpRequest "$@")"
            ;;        
        transform)
            echo "$(transform "$@")"
            ;;
        choiceRouter)
            echo "$(choiceRouter "$@")"
            ;;
        scatterGather)
            echo "$(scatterGather "$@")"
            ;;
        jsonLogger)
            echo "$(jsonLogger "$@")"
            ;;
        log)
            echo "$(log "$@")"
            ;;
        flow)
            echo "$(flow "$@")"
            ;;
        sub-flow)
            echo "$(subFlow "$@")"
            ;;
        flow-ref)
            echo "$(flowRef "$@")"
            ;;
        try)
            echo "$(tryScope "$@")"
            ;;
        munit:config)
            echo "$(munitConfig "$@")"
            ;;
        munit:test)
            echo "$(munitTest "$@")"
            ;;
        munit:set-event)
            echo "$(munitSetEvent "$@")"
            ;;
        munit:assert)
            echo "$(munitAssert "$@")"
            ;;
        munit:mock)
            echo "$(munitMock "$@")"
            ;;
        *)
            echo "Unknown element: $element" >&2
            exit 1
    esac
}
main $@
