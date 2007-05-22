#!/bin/bash
# usermem
# Author: redondos [at] gmail.com
#
# This script will list the total number of processes a user is running on a
# system and the total amount of memory used by them.
#
# usage: usermem [ username ]
#
# If no arguments are given, the script will output the number of processes
# and memory used by every user on the system who is running at least one
# process.

function calculate {
c=bc=0
	for i in `ps aux|grep $1|awk '{print $6}'`; do 
		c=$((c+1))
		bc=$((bc+i))
		# echo "Added $i = $bc"
	done

c_total=$((c_total+c))
bc_total=$((bc_total+bc/1024))
echo
echo "User: $1"
echo "Processes: $c"
echo "Memory: $((bc/1024)) MiB"
}

if [ "$1" != "" ]; then
	calculate "$1"
else
	for user in $(ls /home); do
		if [ "$(grep ^$user /etc/passwd)" ]; then
			if [ "$(ps aux|grep ^$user|grep -v grep)" ]; then
				calculate "$user"
			fi
		fi
	done
	calculate "root"
fi

echo
echo "Total processes: $c_total"
echo "Total memory: $bc_total MiB"
