size=$(mkisofs -V "$1" -print-size -R -f -J -quiet -joliet-long $2) 
mkisofs -V "$1" -R -f -J -joliet-long "$2" | cdrecord -v -tao dev=/dev/$3 fs=30m -driveropts=burnfree -tsize="$size"s $4 -
