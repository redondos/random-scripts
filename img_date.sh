#!/bin/bash
# TODO: Add support for .thm files describing videos
#	Replace awk with cut

if [ -z $1 ]; then
	echo "usage: $0 [ -r ] [ files ]"
	echo "The optional "-r" flag reverses the changes."
	exit 1
fi

exif_ts() {
	exif "$1" | awk -F\| '/Date.*orig/{print $2; quit}'
}

get_ts() {
	if [[ ! -e $file ]]; then
		return 1
	fi

	case "$file" in
	*mpg|*MPG)
		if [ -e "${file%.*}.thm" ]; then
			ts=$(exif_ts "${file%.*}.thm")
		elif [ -e "${file%.*}.THM" ]; then
			ts=$(exif_ts "${file%.*}.THM")
		else
			ts=$(stat --format="%y" "$file")
		fi
	;;

	*)
		ts=$(exif_ts "$file" 2>/dev/null)
		if [[ -z "$ts" ]]; then
			ts=$(stat --format="%y" "$file")
			ts=${ts:0:19}
		fi
	;;
	esac

	ts=$(sed 's/ *$//' <<< "$ts") # Why doesn't ${ts%% } work?
	ts=${ts//[:-]/}

	echo "$ts"
}

rename_ts() {

	for file in "$@"; do
		if [[ ! -e $file ]]; then
			continue
		fi

		ts=$(get_ts "$file")
		newfile=$(tr "A-Z" "a-z" <<< "$file")
		newfile="${ts/ /T}-$newfile"

		# YYYYmmddThhmmss-$file
		echo "mv -v \"$file\" \"$newfile\""

		# YYmmddhhmm.ss
		# Seconds are superfluous and cause trouble
		# echo touch -acmt ${ts:2:6}${ts:9:4}.${ts:10:2} \"$newfile\"

		# YYmmddhhmm
		echo touch -acmt ${ts:2:6}${ts:9:4} \"$newfile\"
	done
}

restore() {
	for file in "$@"; do
		if [[ $file != ${file##*-} ]]; then
			echo mv -v \"$file\" \"${file##*-}\"
		fi
	done
}

organize() {
	for file in "$@"; do
		if [[ ! -e $file ]]; then
			continue
		fi

		ts=$(get_ts "$file")

		dir=${ts:0:4}-${ts:4:2}-${ts:6:2}
		if [[ -e $dir && ! -d $dir ]]; then
			echo '# "$dir" exists but it is not a directory, skipping.'
			continue
		elif [[ ! -e $dir ]]; then
			echo mkdir $dir "2>/dev/null"
		fi

		echo mv -v \"$file\" $dir
	done
}

case "$1" in
	-r)	shift
		restore "$@"
	;;
	-o)	shift
		organize "$@"
	;;
	*)	rename_ts "$@"
	;;
esac

echo "# This is a preview only. Run with $0 |sh to apply the changes."
