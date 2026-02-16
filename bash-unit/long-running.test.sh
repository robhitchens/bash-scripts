#!/usr/bin/env bash
source bsunit-lib.sh

#TEST
function longRunningTest {
	echo "running long running test" >&2
	sleep 65
	return 0
}
