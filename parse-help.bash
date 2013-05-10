#!/bin/bash

while true; do
    read line || break
    case $line in 
	--*) echo "Long: $line";;
	-*) echo "Short: $line";;
	*) echo "None: $line";;
    esac
done
