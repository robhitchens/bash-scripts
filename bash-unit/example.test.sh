#!/usr/bin/env bash

# Assuming that bsunit-lib.sh is symlinked in /usr/local/bin/ folder.
source bsunit-lib.sh

#SETUP
function setup {
	echo "executed setup function"
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
