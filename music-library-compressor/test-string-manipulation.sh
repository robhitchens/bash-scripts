#!/usr/bin/env bash

IFS=$'\n'
string="/tmp/test1:/tmp/test2"
split=(${string//:/$'\n'})
#echo "$split"
echo "${split[0]} ${split[1]}"
