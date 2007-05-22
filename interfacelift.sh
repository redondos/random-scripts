#!/bin/bash
width=$(echo $2 | awk -Fx '{print $1}')
height=$(echo $2 | awk -Fx '{print $2}')
if [ "$3" == "" ]; then sort=rating; fi
sort=$3
curl "http://interfacelift.com/wallpaper/index.php?w=$width&h=$height&sort=$sort&id=&page=$1" | grep "_$width" | awk '{print $3}' | sed 's/href=//;s/"//g' | while read picture; do wget -nc -T2 -t 10 "http://interfacelift.com$picture"; done
