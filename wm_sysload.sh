#!/bin/bash

SEP=" | "

shopt -s nullglob	# for $newmail

while sleep 0.5; do
	s=

	## CPU usage
	#zsh
	# < /proc/stat \
	# read	_ stat[user] stat[nice] stat[system] stat[idle] stat[iowait]	\
	#	stat[irq] stat[softirq] _
	# s+="[$((stat[idle]-stat_old[idle]))]"
	# stat_old=$stat

	#bash
  # key: cpu user nice system idle iowait irq softirq 0
  stat=($(read line < /proc/stat; echo "$line"))                                     
	(( usage = (stat[1]-stat_old[1]) + (stat[2]-stat_old[2]) + (stat[3]-stat_old[3]) ))
	(( idle = stat[4]-stat_old[4] ))
	percentage=$(printf %.2d $(( 100*usage/(usage+idle) )) )
  [[ ${stat_old[4]} ]] && s+="CPU: $percentage%" || s+="CPU: 00%"
  stat_old=("${stat[@]}")

	## Load average
	# key: 1 5 15 running highest_pid
  loadavg=($(read line < /proc/loadavg; echo "$line"))
	[[ $s ]] && s+=" - ${loadavg[0]} ${loadavg[1]} ${loadavg[2]}"

	## Inbox
	newmail=(~/.maildir/new/*)
	s+=$SEP
	s+="m: ${#newmail}"

	## Date
	s+=$SEP
	s+="$(date "+%a %d-%m-%y %H:%M:%S")"
	
	echo "$s"

done

# vim: ts=2
