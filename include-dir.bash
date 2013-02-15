#!/bin/bash

FILENAME="$0"
PATTERN="^[ \t]*[#\.]include[ \t]*\([^ \t][^ \t]*\/\)\*.*$"
FILE="$1"
if [ "x$1" == "x" ]; then
    FILE=/dev/stdin
fi

function recurse () {
    (
	cd $1
	for i in *; do
	    if [ -d "$i" ]; then
		recurse $i
	    else
		echo "#include `pwd`/$i"
	    fi
	done
    )
}

cat $FILE | while read line; do
    tmp=$(echo $line | sed -n -e "s/$PATTERN/\1/igp")
    if [ "x$tmp" == "x" ]; then
	echo $line
    else
	echo "TMP=$tmp TMP"
	recurse "$tmp"
    fi
done