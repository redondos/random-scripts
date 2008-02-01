#!/bin/zsh
# Download images from digital camera
# mount /media/camera1
camera=(usbdisk T1 camera camera1)
destination=~/pictures/tmp
# camera_num=2

emulate zsh
setopt braceccl

if [[ =exif == "=exif" ]]; then
	echo "exif(1) not found. Exiting."
	exit 1
fi

case "$1" in
	"") CMD=mv;;
	-c) CMD=cp;echo "Copying, not moving";shift;;
	*) CMD=mv;shift;;
esac

rename_move() {
	act=1
	for file in $(find "$1" -type f 2>/dev/null); do
		if [[ $file:e:l == jpg ]]; then
			date=${${"$(exif -t "Date and Time" -m $file)"% *}//:/-}
		fi
		if [ -z $date ]; then date=$(find $file -printf "%TY-%Tm-%Td\n"); fi
		if [ ! -d "$destination/$date" ]; then mkdir "$destination/$date"; fi
		$CMD -v "$file" "$destination/$date" && act=0
	done
	return $act
}

if [ -z "$1" ]; then
	for dir in "${camera[@]}"; do
		rename_move /media/$dir && print "All images successfully grabbed from /media/$dir."
	done
	for i in {a-z}; do
		dir=sd${i}1
		if [[ -d /media/$dir ]]; then
			read -q "?/media/$dir found. Use? "
			if [[ $REPLY == y ]]; then
				rename_move "/media/$dir" && print "All images successfully grabbed from /media/$dir."
			fi
		fi
	done
else
	rename_move "$1" && echo "All images successfully sorted."
fi

