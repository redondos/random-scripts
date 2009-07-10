
maildir_source=~/Maildir
maildir_target=~/Mail	# It will remove everything in here, so be careful.
separator="." 		# Use "/" if you want directory-separated mailboxes. (IMAP-style)


function parse {
	if [ "$1" = "." ] || [ "$1" = ".." ]; then return 1; fi
	path="$(echo $1 | sed 's/^\.//')"	# Remove leading dot

	if [ -z "$2" ]; then step=1; else step="$2"; fi

	if [ -z "$3" ]; then parent="$maildir_target"; else parent="$3"; fi

	new_symlink=$(echo "$path" | awk -F. "{print \$$step}")


	fields_num=$(echo "$path" | awk -F. "{print NF}")

	if [ $fields_num -gt $step ]; then 
		case "$separator" in
			"/")
				mkdir -p "$parent/$new_symlink" 2> /dev/null
				parse "$path" $((step+1)) "$parent/$new_symlink";;
			".")
				if  [ "$parent"  == "$maildir_target" ]; then 
					parse "$path" $((step+1)) "$parent/$new_symlink"
					continue
				fi
				parse "$path" $((step+1)) "$parent.$new_symlink";;
			*)
				echo "Unsupported separator, refusing to run."
				exit 1;;
		esac
	else
		if [ "$step" == "1" ]; then
			echo "Creating symlink: $parent/$new_symlink -> $maildir_source/.$path"
			ln -s  "$maildir_source/.$path" "$parent/$new_symlink"
		else
			echo "Creating symlink: $parent$separator$new_symlink -> $maildir_source/.$path"
			ln -s  "$maildir_source/.$path" "$parent$separator$new_symlink"
		fi
		continue
	fi
}

rm -rf $maildir_target/*
for i in "$maildir_source"/.*; do parse "$(basename "${i}")"; done
exit $?
