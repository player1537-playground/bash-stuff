#!/bin/sh

function summd5 () {
    md5sum $1 | sed "s/^\([^ ]*\).*/\1/"
}

function recurse () {
    (
	cd $1
	for i in *; do
	    echo "$i"
	    if [ -d "$i" ]; then
		recurse "$i"
	    else
		summd5 "$i" >> /tmp/md5sum
		summd5 /tmp/md5sum > /tmp/md5sum
	    fi
	done
    )
}

> /tmp/md5sum
recurse .
echo ""
echo "md5sum: `cat /tmp/md5sum`"
