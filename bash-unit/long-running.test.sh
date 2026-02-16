#!/usr/bin/env bash
source bsunit-lib.sh

#TEST
function longRunningTest {
	echo "running long running test" >&2
	local count=15
	while ((count != 0)); do
		echo -n "$count " >&2
		sleep 1
		((count--))
	done
	#return 0
}
