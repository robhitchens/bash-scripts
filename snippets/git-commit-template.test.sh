#!/usr/bin/env bash

source bsunit-lib.sh

#TEST
function gitCommitTemplate_noArguments_test {
	local output="$(git-commit-template)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace ":changeNumber:: :title:

Why:

:why:

What:

:what:"
}

#TEST
function gitCommitTemplate_providedChangeNumber_test {
	local expected="1234: :title:

Why:

:why:

What:

:what:"

	local output="$(git-commit-template --changeNumber 1234)"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "$expected"

	local shorthandOutput="$(gct -c 1234)"

	assert "$shorthandOutput" isNotEmpty &&
		assert "$shorthandOutput" equalsIgnoringWhitespace "$expected"
}

#TEST
function gitCommitTemplate_providedTitle_test {
	local expected=":changeNumber:: A commit message title

Why:

:why:

What:

:what:"

	local output="$(git-commit-template --title 'A commit message title')"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "$expected"

	local shorthandOutput="$(gct -t 'A commit message title')"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "$expected"
}

#TEST
function gitCommitTemplate_providedWhy_test {
	local expected=":changeNumber:: :title:

Why:

A multiline
why message
for the template

What:

:what:"

	local output="$(git-commit-template --why 'A multiline
why message
for the template')"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "$expected"

	local shorthandOutput="$(gct -W 'A multiline
why message
for the template')"

	assert "$shorthandOutput" isNotEmpty &&
		assert "$shorthandOutput" equalsIgnoringWhitespace "$expected"
}

#TEST
function gitCommitTemplate_providedMultipleWhatArgs_test {
	local expected=":changeNumber:: :title:

Why:

:why:

What:

- First what
- Second what"

	local output="$(git-commit-template --what 'First what' --what 'Second what')"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "$expected"

	local shorthandOutput="$(gct -w 'First what' -w 'Second what')"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "$expected"
}

#TEST
function gitCommitTemplate_providedAllArgs_test {
	local expected="1234: A commit title

Why:

Some why message describing the intent of the changes

What:

- First what
- Second what"

	local output="$(git-commit-template --changeNumber 1234 --title 'A commit title' --why 'Some why message describing the intent of the changes' --what 'First what' --what 'Second what')"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "$expected"

	local shorthandOutput="$(gct -c 1234 -t 'A commit title' -W 'Some why message describing the intent of the changes' -w 'First what' -w 'Second what')"

	assert "$output" isNotEmpty &&
		assert "$output" equalsIgnoringWhitespace "$expected"
}
