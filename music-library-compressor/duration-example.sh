#!/usr/bin/env bash

start=`date +%s`
sleep 10
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
