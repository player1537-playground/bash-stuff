#!/bin/bash

depth='|--'
last_depth=0
depth_num=0

ls -R | while true; do
    read line || break
    case "x$line" in
	x./*:)
	    last_depth="$depth_num"
	    depth=$(echo "$line" | sed -e 's_[^/]__g')
	    depth_num=$((${#depth} * 4))
#	    depth="$(echo "$line" | sed -e 's_._ _g')|$(x ' ' $((depth_num - 1)))"
	    depth="|$(x ' ' $((depth_num + 1)))|--"
	    line=${line#./}
	    line=${line%:}
	    if [ $last_depth -lt $depth_num ]; then
		echo "|$(x ' ' $((last_depth + 1)))\`-- ${line%:}"
	    else
		echo "|$(x - $depth_num) ${line%:}"
	    fi
	    ;;
	x.*)
	    ;;
	x)
	    ;;
	x*)
	    echo "$depth $line"
	    ;;
    esac
done