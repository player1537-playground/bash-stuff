#!/bin/bash

WORK=$PWD/work
NEWWORK=$PWD/.work

case $1 in
    mount)

	sudo mkfs -t ext2 -q /dev/ram1 $((1024 * 32))

	if [ -d $WORK ]; then
	    rm -rf $NEWWORK
	    mv $WORK $NEWWORK
	fi
	mkdir -p $WORK

	sudo mount /dev/ram1 $WORK

	if [ -d $NEWWORK ]; then
	    sudo mv $NEWWORK/* $WORK
	    rm $NEWWORK -r
	fi
	;;
    umount)
	mkdir -p $NEWWORK
	mv $WORK/* $NEWWORK
	sudo umount $WORK
	mv $NEWWORK/* $WORK
	;;
esac
