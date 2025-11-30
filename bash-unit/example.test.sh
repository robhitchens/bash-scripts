#!/usr/bin/env bash

source ./bash-unit/bsunit-lib.sh

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
