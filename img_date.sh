#!/bin/bash
# TODO: Add support for .thm files describing videos
#	Replace awk with cut
if [ -z $1 ]; then
	echo "usage: $0 EXPRESSION
	Where EXPRESSION is a list of filenames separated by spaces."
fi
for file in $@
do
	TS=`exif "$file" |grep Date|head -n 1|awk -F "|" '{print $2}'`
	if [ -n "$TS" ] ; then 
	# We have EXIF data.
		TS_date=$(echo $TS | awk '{print $1}')
		TS_time=$(echo $TS | awk '{print $2}')
		TS_date_y=$(echo $TS_date | awk -F":" '{print $1}')
		TS_date_m=$(echo $TS_date | awk -F":" '{print $2}')
		TS_date_d=$(echo $TS_date | awk -F":" '{print $3}')
		TS_time_h=$(echo $TS_time | awk -F":" '{print $1}')
		TS_time_m=$(echo $TS_time | awk -F":" '{print $2}')
		TS_time_s=$(echo $TS_time | awk -F":" '{print $3}')

		NEW_FILENAME="$TS_date_y $TS_date_m $TS_date_d T $TS_time_h $TS_time_m $TS_time_s"
		NEW_FILENAME="${NEW_FILENAME// /}-${file/JPG/jpg}"
		# file_timestamp=`echo $timestamp|sed 's/://g'|sed 's/ /-/'|cut -c -15`
		echo "mv -v "$file" \"$NEW_FILENAME\""
		echo touch -acmt $(expr substr $TS_date_y 3 2)$TS_date_m$TS_date_dT$TS_time_h$TS_time_m.$TS_time_s "$NEW_FILENAME"
	else
	# No EXIF data.
		TS=$(stat --format="%y" "$file")
		TS_date=$(echo $TS | awk '{print $1}')
		TS_date=${TS_date//-/}
		TS_time=$(echo $TS | awk '{print $2}')
		TS_time=${TS_time//:/}
		TS_time=$(echo $TS_time | cut -c 1-6)

		NEW_FILENAME="$TS_date T $TS_time"
		NEW_FILENAME="${NEW_FILENAME// /}-${file/JPG/jpg}"

		echo "mv -v "$file" \"$NEW_FILENAME\""

	fi
done

if [ -n "$1" ]; then echo "# This is a preview only. Run with $0 |sh to apply the changes."; fi
