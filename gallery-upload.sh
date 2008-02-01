#!/bin/bash
PN=`basename "$0"`
VER='0.1'
Usage () {
	echo >&2 "$PN - upload pictures to G2, version $VER
usage:	$PN [-a <album>] [-nc]
	-a: specify the album name, otherwise it will be taken from $PWD
	-nc: no convert - do not shrink the images 
	-v: verbose output

The default behavior is to shrink every image in the current working directory,
create an album on the gallery using its name and upload the images there."
	exit 1
}

USER=$(whoami)
upload () {
	[ $TEST ] ||	galleryadd.pl -G 2 -g http://gallery.redondos.biz -u $USER -p $password -a $album_id *.jpg | tee $tmpfile
	[ $TEST ] ||	egrep "Upload.*OK]" $tmpfile | awk '{print $2}' >> .upload.log
		cat .upload.log | xargs rm -v 2>/dev/null
}

tmpfile=/tmp/gallery-upload.log
logfile=.upload.log

while [ $# -gt 0 ] 
do
    case "$1" in
        -a)     album_name="$2";;
        -p)     password="$2";;
        -nc)    NOCONVERT=yes;;
	-v)     VERBOSE=yes;;
	-r)	RECURSIVE=yes;;
	-t)	TEST=yes;;
        --)     shift; break;;
        -h)     Usage;;
        -*)     Usage;;
        #*)      break;;
    esac
    shift
done

if [ -z "$album_name" ]; then album_name="$(pictures_dirname)"; fi
[ $VERBOSE ] && echo "album_name=$album_name"
[ $VERBOSE ] && echo "This script will resize the images in the current directory to 1024x768 pixels."
echo "Using album: \"$album_name\"."
if [ -z $password ]; then
	echo "Then enter your gallery password: "
	stty -echo
	read password
	stty echo
fi
for j in $(find . -name "*.JPG"); do mv ${j} ${j%.JPG}.jpg; done
[ $NOCONVERT ] || for i in $(find . -name "*.jpg"); do
	echo "Processing: $i"
#	image_size=$(identify $i |awk '{print $3}')
#	image_width=$(echo $image_size |awk -Fx '{print $1}')
#	image_height=$(echo $image_size |awk -Fx '{print $2}')
#	echo "Width: $image_width"
#	echo "Height: $image_height"
convert -resize 1024x1024 "$i" "$i"

#		if [ "${image_height}" -gt ${image_width} ]; then
#			if (( ${image_height} / 1024 * 1024 != 1024 )); then
#				echo "Resizing $i to 1024x768. Current size: ${image_size}"
#				convert -size 768x1024 "$i" "$i"
#				# convert -size 768x1024 $i ${i%.jpg}.small.jpg
#			fi
#		else
#			if (( ${image_width} / 1024 * 1024 != 1024 )); then
#				echo "Resizing $i to 1024x768. Current size: ${image_size}"
#				convert -size 1024x768 "$i" "$i"
#				# convert -size 1024x768 $i ${i%.jpg}.small.jpg
#
#			fi
#		fi
done
# TODO: Find a way to create albums.
# Tip: galleryadd.pl -l | grep $albumname | sed 's/Album:[ ]*//' | sort | tail -n 1 | awk '{print $1}'

# G2add.pl
# Doesn't work. It's outdated, don't use it.
# g2add.pl  -l http://gallery.redondos.biz -u redondos -p $password -a "$(pictures_dirname)" *.jpg -c

# galleryadd.pl
# album_id=$(galleryadd.pl -G 2 -g http://gallery.redondos.biz -p $password -l | awk "/$(pictures_dirname)/  {\$1 = \"\"; sub(/^[ \t]+/, \"\"); print \$1 | "sort"}" | tail -n 1)

album_id=$(galleryadd.pl -G 2 -g http://gallery.redondos.biz -p $password -l | awk "/$album_name/  {\$1 = \"\"; sub(/^[ \t]+/, \"\"); print \$1 | \"sort\"}" | tail -n 1)
echo "Command: galleryadd.pl -G 2 -g http://gallery.redondos.biz -p $password -a $album_id *.jpg"
[ $RECURSIVE ] && while [ $(ls|wc -l) != 0 ]; do
	upload
done || upload

[ $RECURSIVE ] && echo "All files successfully uploaded. Thank you for your patronage." 
rm $tmpfile

