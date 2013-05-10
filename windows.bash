#!/bin/bash

function conv() {
    local value null
    value="$*"
    null=$'\000'
    echo ${value// /$null}
}

function unconv() {
    local value null
    value="$@"
    null=$'\000'
    echo ${value//$null/ }
}

function new-window() {
    local x y width height title
    x=$(conv $1)
    y=$(conv $2)
    width=$(conv $3)
    height=$(conv $4)
    title=$(conv $5)
    echo "x:$x,y:$y,w:$width,h:$height,t:$title"
}

function get() {
    local prop obj
    prop=$1
    obj=$2
    expr $obj : ".*$prop:\([^,]*\).*"
}

function put-cursor() {
    local x y
    x=$1
    y=$2
    echo -ne "\033[${y};${x}f"
}

function x() {
    local printwhat numtimes tmp
    printwhat=$1
    numtimes=$2
    tmp=$(printf "%${numtimes}s" " ")
    tmp="${tmp// /$printwhat}"
    echo "$tmp"
}

function padright() {
    local x len
    x=$1
    len=$2
    if [ ${#x} -gt $len ]; then
	x=${x:1:$len}
    fi
    if [ ${#x} -lt $len ]; then
	echo "${x}$(x ' ' $(($len - ${#x})))"
    else
	echo "${x}"
    fi
}

function args() {
    local arg
    for arg; do
	echo [$arg] >&2
    done
}

function wordwrap() {
    local text len maxlines i word line
    text="$1 "
    len=$2
    maxlines=$3
#    echo [$1] [$2] [$3] [$4] >&2
    i=0
    word=
    line=
    while ((i < maxlines)); do
#	echo rawr $line >&2
	while [ $((${#line} + ${#word})) -lt $len ]; do
#	    echo RAWR ${#line} ${#word} ${len} >&2
	    word=${text%% *}
	    if [ $((${#line} + ${#word})) -lt $len ]; then
		text=${text#* }
		line+="$word "
	    fi
	done
	padright "$line" $len
	line=
	((i++))
    done
}

function output-text-window() {
    local starty endy x line IFS
    starty=$1
    endy=$2
    x=$3
    cat -n - | while true; do
	IFS=$'\t' read cury line || break
	echo [${cury# }] [$line] >&2
	[[ cury < endy ]] || break
	put-cursor $x $((cury + starty))
	echo "|${line}|"
    done
}

function draw-window() {
    local window text x y height width title cury line
    window=$1
    text=$2
    x=$(get x $window)
    y=$(get y $window)
    endy=$(($y + $(get h $window)))
    width=$(get w $window)
    title=$(unconv $(get t $window))
    cury=$y
    put-cursor $x $cury
    echo "+$(x '-' $(($width - 2)))+"
    ((cury++))
    put-cursor $x $cury
    echo "|X | $(padright "$title" $(($width - 6)))|"
    ((cury++))
    put-cursor $x $cury
    echo "+$(x '-' $(($width - 2)))+"
    wordwrap "$text" $(($width - 2)) $(($endy - $cury)) | output-text-window $cury $endy $x
    put-cursor $x $endy
    echo "+$(x '-' $(($width - 2)))+"
}

draw-window "$(new-window 4 6 20 8 'Test Title')" 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce convallis dui eu nunc ornare commodo. Nam commodo consequat dapibus. Nunc vitae ipsum dolor. Ut vel purus neque. Pellentesque lobortis elit a tellus sollicitudin sit amet consectetur dolor condimentum. In eget metus vitae nisi porttitor pharetra vitae et libero. In viverra mi vitae arcu euismod a vestibulum diam congue. Duis cursus, purus non dapib'
draw-window "$(new-window 18 15 29 12 'Test Title')" 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce convallis dui eu nunc ornare commodo. Nam commodo consequat dapibus. Nunc vitae ipsum dolor. Ut vel purus neque. Pellentesque lobortis elit a tellus sollicitudin sit amet consectetur dolor condimentum. In eget metus vitae nisi porttitor pharetra vitae et libero. In viverra mi vitae arcu euismod a vestibulum diam congue. Duis cursus, purus non dapib'

