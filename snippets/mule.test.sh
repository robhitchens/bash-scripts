#!/usr/bin/env bash

source bsunit-lib.sh

readonly uuidRegex='[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

#TEST
function muleRoot_test {
	local output="$(mule muleRoot)"

	assert "$output" equals "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd http://www.mulesoft.org/schema/mule/json-logger http://www.mulesoft.org/schema/mule/json-logger/current/mule-json-logger.xsd http://www.mulesoft.org/schema/mule/http http://www.mulesoft.org/schema/mule/http/current/mule-http.xsd http://www.mulesoft.org/schema/mule/ee/core http://www.mulesoft.org/schema/mule/ee/core/current/mule-ee.xsd'
     xmlns:xsi          = http://www.w3.org/2001/XMLSchema-instance
     xmlns:ee           = http://www.mulesoft.org/schema/mule/ee/core
     xmlns:http         = http://www.mulesoft.org/schema/mule/http
     xmlns:json-logger  = http://www.mulesoft.org/schema/mule/json-logger
     xmlns              = http://www.mulesoft.org/schema/mule/core
     xmlns:doc          = http://www.mulesoft.org/schema/mule/documentation)
{
   :children: 
}"
}

#TEST
function muleRoot_shorthand_test {
	local output="$(mule mr)"

	assert "$output" equals "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd http://www.mulesoft.org/schema/mule/json-logger http://www.mulesoft.org/schema/mule/json-logger/current/mule-json-logger.xsd http://www.mulesoft.org/schema/mule/http http://www.mulesoft.org/schema/mule/http/current/mule-http.xsd http://www.mulesoft.org/schema/mule/ee/core http://www.mulesoft.org/schema/mule/ee/core/current/mule-ee.xsd'
     xmlns:xsi          = http://www.w3.org/2001/XMLSchema-instance
     xmlns:ee           = http://www.mulesoft.org/schema/mule/ee/core
     xmlns:http         = http://www.mulesoft.org/schema/mule/http
     xmlns:json-logger  = http://www.mulesoft.org/schema/mule/json-logger
     xmlns              = http://www.mulesoft.org/schema/mule/core
     xmlns:doc          = http://www.mulesoft.org/schema/mule/documentation)
{
   :children: 
}"
}

#TEST
function munitRoot_test {
	local output="$(mule munitRoot)"

	assert "$output" equals "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd   http://www.mulesoft.org/schema/mule/munit http://www.mulesoft.org/schema/mule/munit/current/mule-munit.xsd   http://www.mulesoft.org/schema/mule/munit-tools  http://www.mulesoft.org/schema/mule/munit-tools/current/mule-munit-tools.xsd'
     xmlns:xsi          = http://www.w3.org/2001/XMLSchema-instance
     xmlns:munit        = http://www.mulesoft.org/schema/mule/munit
     xmlns:munit-tools  = http://www.mulesoft.org/schema/mule/munit-tools
     xmlns              = http://www.mulesoft.org/schema/mule/core
     xmlns:doc          = http://www.mulesoft.org/schema/mule/documentation)
{
    :children:
}"
}

#TEST
function munitRoot_shorthand_test {
	local output="$(mule mur)"

	assert "$output" equals "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd   http://www.mulesoft.org/schema/mule/munit http://www.mulesoft.org/schema/mule/munit/current/mule-munit.xsd   http://www.mulesoft.org/schema/mule/munit-tools  http://www.mulesoft.org/schema/mule/munit-tools/current/mule-munit-tools.xsd'
     xmlns:xsi          = http://www.w3.org/2001/XMLSchema-instance
     xmlns:munit        = http://www.mulesoft.org/schema/mule/munit
     xmlns:munit-tools  = http://www.mulesoft.org/schema/mule/munit-tools
     xmlns              = http://www.mulesoft.org/schema/mule/core
     xmlns:doc          = http://www.mulesoft.org/schema/mule/documentation)
{
    :children:
}"
}

#TEST
function httpRequest_noArgs_test {
	# NOTE: should probably just have the template not auto inject uuid for http:request template.
	local output="$(mule http:request | sed -E "s/$uuidRegex/':doc:id:'/")"

	assert "$output" equals "http:request(method     = ':method:'
             doc:name   = ':name:'
             doc:id     = ':doc:id:'
             config-ref = ':config-ref:'
             path       = ':path:'
             sendCorrelationId = ALWAYS
             correlationId = #[correlationId]
             target     = ':target:')
{
    
    
    
    
}"
}

#TEST
function httpRequest_noArgs_shorthand_test {
	local output="$(mule hr | sed -E "s/$uuidRegex/':doc:id:'/")"

	assert "$output" equals "http:request(method     = ':method:'
             doc:name   = ':name:'
             doc:id     = ':doc:id:'
             config-ref = ':config-ref:'
             path       = ':path:'
             sendCorrelationId = ALWAYS
             correlationId = #[correlationId]
             target     = ':target:')
{
    
    
    
    
}"
}

#TEST
function httpRequest_allArgs_test {
	local output="$(mule http:request body headers uriParams queryParams)"

	assert "$(echo "$output" | sed -E "s/$uuidRegex/':doc:id:'/")" equals "http:request(method     = ':method:'
             doc:name   = ':name:'
             doc:id     = ':doc:id:'
             config-ref = ':config-ref:'
             path       = ':path:'
             sendCorrelationId = ALWAYS
             correlationId = #[correlationId]
             target     = ':target:')
{
    http:body = '''#[%dw 2.0
output application/json skipNullOn=\"everywhere\"
---
{}]'''    
    http:headers = '''#[%dw 2.0
import p from Mule
output application/java
---
{
    client_id: p('secure::{api}.{system}.client-id'),
    client_secret: p('secure::{api}.{system}.client-secret')
}]'''
    http:uri-params = '''#[%dw 2.0
output application/java
---
{}]'''
    http:query-params = '''#[%dw 2.0
output application/java
---
{}]'''
}"
}

#TEST
function httpRequest_allArgs_shorthand_test {
	local output="$(mule hr b h u q)"

	assert "$(echo "$output" | sed -E "s/$uuidRegex/':doc:id:'/")" equals "http:request(method     = ':method:'
             doc:name   = ':name:'
             doc:id     = ':doc:id:'
             config-ref = ':config-ref:'
             path       = ':path:'
             sendCorrelationId = ALWAYS
             correlationId = #[correlationId]
             target     = ':target:')
{
    http:body = '''#[%dw 2.0
output application/json skipNullOn=\"everywhere\"
---
{}]'''    
    http:headers = '''#[%dw 2.0
import p from Mule
output application/java
---
{
    client_id: p('secure::{api}.{system}.client-id'),
    client_secret: p('secure::{api}.{system}.client-secret')
}]'''
    http:uri-params = '''#[%dw 2.0
output application/java
---
{}]'''
    http:query-params = '''#[%dw 2.0
output application/java
---
{}]'''
}"
}

#TEST
function transform_noArgs_test {
	local output="$(mule transform)"

	assert "$output" equals "ee:transform(doc:name = 'Transform Message')
{
    ee:message
    
    
}"
}

#TEST
function transform_noArgs_shorthand_test {
	local output="$(mule tr)"

	assert "$output" equals "ee:transform(doc:name = 'Transform Message')
{
    ee:message
    
    
}"
}

#TEST
function transform_allArgs_test {
	local output="$(mule transform payload variables 1)"
	assert "$output" equals "ee:transform(doc:name = 'Transform Message')
{
    ee:message
{
    ee:set-payload = '''#[%dw 2.0
output application/json
---
{}]'''
}
    ee:variables
{
    ee:set-variable(variableName = ':name-0:') = '''#[%dw 2.0
output application/json
---
{}]'''

}
 
}"
}

#TEST
function transform_allArgs_shorthand_test {
	local output="$(mule tr p v 1)"
	assert "$output" equals "ee:transform(doc:name = 'Transform Message')
{
    ee:message
{
    ee:set-payload = '''#[%dw 2.0
output application/json
---
{}]'''
}
    ee:variables
{
    ee:set-variable(variableName = ':name-0:') = '''#[%dw 2.0
output application/json
---
{}]'''

}
 
}"
}

#TEST
function choiceRouter_noargs_test {
	local output="$(mule choiceRouter)"

	assert "$output" equals "choice(doc:name=':doc:name:')
{


}"
}

#TEST
function choiceRouter_noargs_shorthand_test {
	local output="$(mule cr)"

	assert "$output" equals "choice(doc:name=':doc:name:')
{


}"
}

#TEST
function choiceRouter_allArgs_shorthand_test {
	local output="$(mule cr w 1 o)"

	assert "$output" equals "choice(doc:name=':doc:name:')
{
    when(expression='#[:expression:]')
{
    :children:
}
    otherwise {
    :children:
}
}"
}

# TODO add more unit tests validating behavior of all template commands.
# TODO add test coverage for bad input to commands.
# TODO add simple test for attribute replacement
# TODO add test to validate stdin
# TODO add test to validate wrapping
# TODO add test to validate wrap replace attributes
# TODO add test to validate nesting.
