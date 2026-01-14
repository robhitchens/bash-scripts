#!/usr/bin/env bash -i

# Assuming that bsunit-lib.sh is symlinked in /usr/local/bin/ folder.
source bsunit-lib.sh

#SETUP
function setup {
	echo "executed setup function"
	mock initialize cat
	return 0
}

#TEARDOWN
function teardown {
	echo "executed teardown function"
	return 0
}

#TEST
function passingTest {
	echo "executed passingTest"
	return 0
}

#TEST
function failingTest {
	echo "executed failingTest"
	return 1
}

#TEST
function matchesExample {
	local expected="1st line
    second line s/second/2nd/ something else
    3rd line"
	local actual="1st line
    second line something else
    3rd line"

	assert "$actual" matches "$expected"
}

#TEST
function assertionFailure {
	local expected="true"
	local actual="false"

	assert "$actual" equals "$expected"
}

#TEST
function mockInitTest {
	# TODO need to test mocking cat in setup method
	mock initialize "cat"

	local output=$(cat "")

	assert "$output" isEmpty
	verify cat called 1
	# TODO need to add hook to invoke clearMocks after tests execution.
	# TODO could add handling of mock initialization and clearing using 'annotations' (a.k.a comments) to let the test runner control thise behavior.
}

#TEST
function mockWhenTest {
	mock initialize cat
	mock when cat then echo "some value"

	local output=$(cat "")

	assert "$output" equals "some value"
	verify cat called 1
}
