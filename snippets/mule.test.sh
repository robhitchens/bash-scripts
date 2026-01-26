#!/usr/bin/env bash

source bsunit-lib.sh

readonly uuidRegex='[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

# TODO could reduce the amount of tests by adding support for parameterized tests somehow, at least parameterized input.

#TEST
function muleRoot_test {
	local output="$(mule muleRoot)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd http://www.mulesoft.org/schema/mule/json-logger http://www.mulesoft.org/schema/mule/json-logger/current/mule-json-logger.xsd http://www.mulesoft.org/schema/mule/http http://www.mulesoft.org/schema/mule/http/current/mule-http.xsd http://www.mulesoft.org/schema/mule/ee/core http://www.mulesoft.org/schema/mule/ee/core/current/mule-ee.xsd'
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

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd http://www.mulesoft.org/schema/mule/json-logger http://www.mulesoft.org/schema/mule/json-logger/current/mule-json-logger.xsd http://www.mulesoft.org/schema/mule/http http://www.mulesoft.org/schema/mule/http/current/mule-http.xsd http://www.mulesoft.org/schema/mule/ee/core http://www.mulesoft.org/schema/mule/ee/core/current/mule-ee.xsd'
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

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd   http://www.mulesoft.org/schema/mule/munit http://www.mulesoft.org/schema/mule/munit/current/mule-munit.xsd   http://www.mulesoft.org/schema/mule/munit-tools  http://www.mulesoft.org/schema/mule/munit-tools/current/mule-munit-tools.xsd'
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

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "mule(xsi:schemaLocation = 'http://www.mulesoft.org/schema/mule/core http://www.mulesoft.org/schema/mule/core/current/mule.xsd   http://www.mulesoft.org/schema/mule/munit http://www.mulesoft.org/schema/mule/munit/current/mule-munit.xsd   http://www.mulesoft.org/schema/mule/munit-tools  http://www.mulesoft.org/schema/mule/munit-tools/current/mule-munit-tools.xsd'
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
function comment_test {
	local output="$(mule comment)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "// [STUDIO:\":content:\"]"
}

#TEST
function comment_shorthand_test {
	local output="$(mule c)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "// [STUDIO:\":content:\"]"
}

#TEST
function comment_test_attribute_replacement {
	local output="$(mule c [ :content: 'TODO some comment value' ])"
	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "// [STUDIO:\"TODO some comment value\"]"
}

#TEST
function httpRequest_noArgs_test {
	# NOTE: should probably just have the template not auto inject uuid for http:request template.
	local output="$(mule http:request | sed -E "s/$uuidRegex/':doc:id:'/")"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "http:request(method     = ':method:'
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

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "http:request(method     = ':method:'
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

	assert "$output" isNotEmpty &&
		assert "$(echo "$output" | sed -E "s/$uuidRegex/':doc:id:'/")" equalsIgnoringWhitespace "http:request(method     = ':method:'
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

	assert "$output" isNotEmpty &&
		assert "$(echo "$output" | sed -E "s/$uuidRegex/':doc:id:'/")" equalsIgnoringWhitespace "http:request(method     = ':method:'
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

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "ee:transform(doc:name = 'Transform Message')
{
    ee:message
    
    
}"
}

#TEST
function transform_noArgs_shorthand_test {
	local output="$(mule tr)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "ee:transform(doc:name = 'Transform Message')
{
    ee:message
    
    
}"
}

#TEST
function transform_allArgs_test {
	local output="$(mule transform payload variables 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "ee:transform(doc:name = 'Transform Message')
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

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "ee:transform(doc:name = 'Transform Message')
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

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "choice(doc:name=':doc:name:')
{


}"
}

#TEST
function choiceRouter_noargs_shorthand_test {
	local output="$(mule cr)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "choice(doc:name=':doc:name:')
{


}"
}

#TEST
function choiceRouter_allArgs_shorthand_test {
	local output="$(mule cr w 1 o)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "choice(doc:name=':doc:name:')
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

#TEST
function scatterGather_noArgs_test {
	local output="$(mule scatterGather)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "scatter-gather(doc:name = Scatter-Gather)
{
 
}"
}

#TEST
function scatterGather_noArgs_shorthand_test {
	local output="$(mule sg)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "scatter-gather(doc:name = Scatter-Gather)
{
 
}"
}

#TEST
function scatterGather_allArgs_test {
	local output="$(mule scatterGather r 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "scatter-gather(doc:name = Scatter-Gather)
{
route {
}
}"
}

#TEST
function scatterGather_allArgs_shorthand_test {
	local output="$(mule sg r 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "scatter-gather(doc:name = Scatter-Gather)
{
route {
}
}"
}

#TEST
function jsonLogger_noArgs_test {
	local output="$(mule jsonLogger)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "json-logger:logger(doc:name   = ':doc:name:'
        config-ref = JSON_Logger_Config
        message    = ':message:')"
}

#TEST
function jsonLogger_noArgs_shorthand_test {
	local output="$(mule jl)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "json-logger:logger(doc:name   = ':doc:name:'
        config-ref = JSON_Logger_Config
        message    = ':message:')"
}

#TEST
function log_noArgs_test {
	local output="$(mule log)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "logger(level=':level:'
message = ':message:')"
}

#TEST
function log_noArgs_shorthand_test {
	local output="$(mule l)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "logger(level=':level:'
message = ':message:')"
}

#TEST
function flow_noArgs_test {
	local output="$(mule flow)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "flow(doc:name = ':name:'
name = ':name:')
{
    :children:
}"
}

#TEST
function flow_noArgs_shorthand_test {
	local output="$(mule f)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "flow(doc:name = ':name:'
name = ':name:')
{
    :children:
}"
}

#TEST
function subflow_noargs_test {
	local output="$(mule sub-flow)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "sub-flow(doc:name = ':doc:name:'
name = ':name:')
{
    :children:
}"
}

#TEST
function subflow_noargs_shorthand_test {
	local output="$(mule sf)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "sub-flow(doc:name = ':doc:name:'
name = ':name:')
{
    :children:
}"
}

#TEST
function try_noArgs_test {
	local output="$(mule try)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "try(doc:name = Try)
{
    :children: 

}"
}

#TEST
function try_noArgs_shorthand_test {
	local output="$(mule t)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "try(doc:name = Try)
{
    :children: 

}"
}

#TEST
function try_allArgs_test {
	local output="$(mule try errorhandler)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "try(doc:name = Try)
{
    :children:
    error-handler(ref = global-error-handler)
}"
}

#TEST
function try_allArgs_shorthand_test {
	local output="$(mule t eh)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "try(doc:name = Try)
{
    :children:
    error-handler(ref = global-error-handler)
}"
}

#TEST
function munitConfig_noArgs_test {
	local output="$(mule munit:config)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:config(name = ':name:')"
}

#TEST
function munitConfig_noArgs_shorthand_test {
	local output="$(mule muc)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:config(name = ':name:')"
}

#TEST
function munitTest_noArgs_test {
	local output="$(mule munit:test)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:test(name = ':name:'
description = ':description:')
{
 
    
    
}"
}

#TEST
function munitTest_noArgs_shorthand_test {
	local output="$(mule mut)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:test(name = ':name:'
description = ':description:')
{
 
    
    
}"
}

#TEST
function munitTest_allArgs_test {
	local output="$(mule munit:test execution validation behavior)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:test(name = ':name:'
description = ':description:')
{
    munit:behavior
{
}
    munit:execution
{
}
    munit:validation
{
}
}"
}

#TEST
function munitTest_allArgs_shorthand_test {
	local output="$(mule mut e v b)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:test(name = ':name:'
description = ':description:')
{
    munit:behavior
{
}
    munit:execution
{
}
    munit:validation
{
}
}"
}

#TEST
function munitSetEvent_noArgs_test {
	local output="$(mule munit:set-event)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:set-event(doc:name = 'set event')
{
 
    
    
}"
}

#TEST
function munitSetEvent_noArgs_shorthand_test {
	local output="$(mule mus)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:set-event(doc:name = 'set event')
{
 
    
    
}"
}

#TEST
function munitSetEvent_allArgs_test {
	local output="$(mule munit:set-event payload variables 1 attributes 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:set-event(doc:name = 'set event')
{
    munit:payload(value = '''#[%dw 2.0
output application/json
---
{}]'''
mediaType = application/json)
  
    munit:variables
{
    munit:variable(key = ':key-0:'
    value = '''#[%dw 2.0
output application/json
---
{}]'''
    mediaType = application/json)
     
}
    munit:attributes 
{
    munit:attribute(key = ':key-0:'
    value = '''#[%dw 2.0
output application/json
---
{}]'''
    mediaType = application/json)
     
 }
}"
}

#TEST
function munitSetEvent_allArgs_shorthand_test {
	local output="$(mule mus p v 1 a 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit:set-event(doc:name = 'set event')
{
    munit:payload(value = '''#[%dw 2.0
output application/json
---
{}]'''
mediaType = application/json)
  
    munit:variables
{
    munit:variable(key = ':key-0:'
    value = '''#[%dw 2.0
output application/json
---
{}]'''
    mediaType = application/json)
     
}
    munit:attributes 
{
    munit:attribute(key = ':key-0:'
    value = '''#[%dw 2.0
output application/json
---
{}]'''
    mediaType = application/json)
     
 }
}"
}

#TEST
function munitAssert_noArgs_test {
	local output="$(mule munit:assert)"

	assert "$output" isEmpty
}

#TEST
function munitAssert_noArgs_shorthand_test {
	local output="$(mule mua)"

	assert "$output" isEmpty
}

#TEST
function munitAssert_equals_test {
	local output="$(mule munit:assert equals)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit-tools:assert-equals(doc:name = 'assert equals'
actual = '#[:actual:]'
expected = '#[:expected:]')"
}

#TEST
function munitAssert_equals_shorthand_test {
	local output="$(mule mua eq)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit-tools:assert-equals(doc:name = 'assert equals'
actual = '#[:actual:]'
expected = '#[:expected:]')"
}

#TEST
function munitAssert_that_test {
	local output="$(mule munit:assert that)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit-tools:assert-that(doc:name = 'assert that'
expression = #[payload]
is = '#[MunitTools::notNullValue()]'
message = ':message:')"
}

#TEST
function munitAssert_that_shorthand_test {
	local output="$(mule mua th)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit-tools:assert-that(doc:name = 'assert that'
expression = #[payload]
is = '#[MunitTools::notNullValue()]'
message = ':message:')"
}

#TEST
function munitVerify_noArgs_test {
	local output="$(mule munit:verify)"

	assert "$output" isEmpty
}

#TEST
function munitVerify_noArgs_shorthand_test {
	local output="$(mule muv)"

	assert "$output" isEmpty
}

#TEST
function munitVerify_allArgs_test {
	local output="$(mule munit:verify call 1 attributes 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit-tools:verify-call(doc:name = 'Verify Call'
atLeast = ':atLeast:'
atMost = ':atMost:'
times = ':times:'
processor = ':processor:'
){

munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
    whereValue=':whereValue-0:')

}
}"
}

#TEST
function munitVerify_allArgs_shorthand_test {
	local output="$(mule muv c 1 a 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "munit-tools:verify-call(doc:name = 'Verify Call'
atLeast = ':atLeast:'
atMost = ':atMost:'
times = ':times:'
processor = ':processor:'
){

munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
    whereValue=':whereValue-0:')

}
}"
}

#TEST
function munitAttributes_noArgs_test {
	local output="$(mule munit:attributes)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
whereValue = ':whereValue-0:')

}"
}

#TEST
function munitAttributes_noArgs_shorthand_test {
	local output="$(mule muat)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
whereValue = ':whereValue-0:')

}"
}

#TEST
function munitAttributes_allArgs_test {
	local output="$(mule munit:attributes 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
whereValue = ':whereValue-0:')

}"
}

#TEST
function munitAttributes_allArgs_shorthand_test {
	local output="$(mule muat 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
whereValue = ':whereValue-0:')

}"
}

#TEST
function munitVariables_noArgs_test {
	local output="$(mule munit:variables)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:variables {
    munit-tools:variable(key = ':key-0:'
value = '''#[%dw 2.0
           output application/json
           ---
           {}]'''
mediaType = 'application/json')

}"
}

#TEST
function munitVariables_noArgs_shorthand_test {
	local output="$(mule muvar)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:variables {
    munit-tools:variable(key = ':key-0:'
value = '''#[%dw 2.0
           output application/json
           ---
           {}]'''
mediaType = 'application/json')

}"
}

#TEST
function munitVariables_allArgs_test {
	local output="$(mule munit:variables 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:variables {
    munit-tools:variable(key = ':key-0:'
value = '''#[%dw 2.0
           output application/json
           ---
           {}]'''
mediaType = 'application/json')

}"
}

#TEST
function munitVariables_allArgs_shorthand_test {
	local output="$(mule muvar 1)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:variables {
    munit-tools:variable(key = ':key-0:'
value = '''#[%dw 2.0
           output application/json
           ---
           {}]'''
mediaType = 'application/json')

}"
}

#TEST
function munitMock_noArgs_test {
	local output="$(mule munit:mock)"

	assert "$output" isEmpty
}

#TEST
function munitMock_noArgs_shorthand_test {
	local output="$(mule mum)"

	assert "$output" isEmpty
}

#TEST
function munitMock_allArgs_test {
	local output="$(mule munit:mock when attribute return)"

	#FIXME update logic to process :children: template properly.
	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:mock-when(doc:name = ':doc:name:'
processor = ':processor:')
{
    :children:
}
munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
    whereValue = ':whereValue:')
}
munit-tools:then-return {
    munit-tools:payload(value = '''#[:payload:]''')
    munit-tools:variables {
    munit-tools:variable(key = ':key:' 
    value     = '''#[:value:]'''
    mediaType = application/json)
    }
    munit-tools:error(typeId = ':typeId:')
}"
}

#TEST
function munitMock_allArgs_shorthand_test {
	local output="$(mule mum w a r)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "
munit-tools:mock-when(doc:name = ':doc:name:'
processor = ':processor:')
{
    :children:
}
munit-tools:with-attributes {
    munit-tools:with-attribute(attributeName = ':attributeName:'
    whereValue = ':whereValue:')
}
munit-tools:then-return {
    munit-tools:payload(value = '''#[:payload:]''')
    munit-tools:variables {
    munit-tools:variable(key = ':key:' 
    value     = '''#[:value:]'''
    mediaType = application/json)
    }
    munit-tools:error(typeId = ':typeId:')
}"
}

#TEST
function dataweave_noArgs_test {
	local output="$(mule dataweave)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "%dw 2.0
output application/json
---
{}"
}

#TEST
function dataweave_noArgs_shorthand_test {
	local output="$(mule dw)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "%dw 2.0
output application/json
---
{}"
}

#TEST
function raiseError_noArgs_test {
	local output="$(mule raise-error)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "raise-error(doc:name    = 'Raise error'
doc:id      = ':doc:id:'
type        = ':type:'
description = ':description:')"
}

#TEST
function raiseError_noArgs_shorthand_test {
	local output="$(mule re)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "raise-error(doc:name    = 'Raise error'
doc:id      = ':doc:id:'
type        = ':type:'
description = ':description:')"
}

#TEST
function raiseError_attributeReplacement_test {
	local output="$(mule re [ :doc:id: 'some id' :type: someType :description: 'some description' ])"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "raise-error(doc:name    = 'Raise error'
doc:id      = 'some id'
type        = 'someType'
description = 'some description')"
}

#TEST
function tryScope_wrap_stdin_test {
	local output="$(echo "some child element" | mule -w t eh)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "try(doc:name = Try)
{
    some child element

    error-handler(ref = global-error-handler)
}"
}

# TODO add more unit tests validating behavior of all template commands.
# TODO add test coverage for bad input to commands.
# TODO add simple test for attribute replacement
# TODO add test to validate stdin
# TODO add test to validate wrapping
# TODO add test to validate wrap replace attributes
# TODO add test to validate nesting.
