#!/usr/bin/env bash

IFS=$'\n'
#declare -a array
#array+='1^'
#array+='2^'
#array+='3'
mkdir -p /tmp/array-test
touch /tmp/array-test/out
> /tmp/array-test/out
echo '1' >> /tmp/array-test/out
echo '2' >> /tmp/array-test/out
echo '3' >> /tmp/array-test/out
#echo "$array" | tail -n1 | sed -E s/\[\^\]/\-/g
#for i in $array; do
#  echo "$i"
#done
read=$(cat /tmp/array-test/out)
echo "$read"
