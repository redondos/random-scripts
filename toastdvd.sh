#!/bin/bash
echo growisofs -Z /dev/hdc -V "$1" -R -J -f -joliet-long $2
echo "Sleeping 2 seconds..."
sleep 2
growisofs -Z /dev/hdc -V "$1" -R -J -f -joliet-long $2
