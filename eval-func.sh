#!/usr/bin/env bash

# TODO, can you have nested functions in bash?
funcString='function doSomething {
    if (( count == 0 )); then
        (( count = 1 ))
    else 
        (( count = count + 1 ))
    fi
    echo "did something, count: $count"
}'

count=0

eval "$funcString"

doSomething
doSomething
doSomething
doSomething
doSomething
doSomething
