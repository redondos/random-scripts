#!/bin/bash

start=1
increment=$2
lines=`cat $1|wc -l`
total=$(($((lines-start))/increment+1))
echo "Number of lines: $lines"
echo "Number of resulting files: $total"
count=1

for i in `seq -f %f $start $increment $lines`; do
	filename=$(/usr/bin/printf %0${#total}d ${count})
	i=${i%.000000}
	echo "sed -n '${i},$((i+increment))p' ${1} > ${filename}.txt"
	sed -n "${i},$((i+increment))p" "${1}" > "${filename}.txt"
	count=$((count+1))
done
