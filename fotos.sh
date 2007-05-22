#!/bin/bash
# Download images from digital camera
# mount /media/camera1
camera=(usbdisk T1)
destination=~/pictures/tmp
# camera_num=2

rename_move() {
	for j in $(find "$1" -type f 2>/dev/null); do
		case "${j: -4}" in .[jJ][pP][gG])
			date=$(exif $j |awk -F \| '/Date and Time \(di/ {print $2}' |awk '{print $1}' |sed s/\:/-/g);;
		esac
		if [ -z $date ]; then date=$(find $j -printf "%TY-%Tm-%Td\n"); fi
		if [ ! -d "$destination/$date" ]; then mkdir "$destination/$date"; fi
		mv -v "$j" "$destination/$date"
	done
}

if [ -z "$1" ]; then
	for i in "${camera[@]}"; do
#		umount "/media/$i" 2> /dev/null
		
#		mount "/media/$i" 2> /dev/null
		rename_move /media/$i && echo "All images successfully moved from /media/$i."
#		umount "/media/$i" 2> /dev/null
	done
else
rename_move $1 && echo "All images successfully sorted."
fi

