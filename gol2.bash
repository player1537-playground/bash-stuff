#!/bin/bash

source twodee-arrays.bash
source graphics.bash

## x
# x str n
# repeats $str $n times, so:
#` x abc 3
#+ would return
#` abcabcabc
#+ Similar to Perl's "str" x n operator
function x() {
    local thing_to_repeat n tmp
    thing_to_repeat=$1
    n=$2
    tmp=$(printf "%${n}s" " ")
    tmp="${tmp// /$thing_to_repeat}"
    echo "$tmp"
}

## onebounds
# onebounds n lo hi
# returns true if lo < n < hi 
function onebounds() {
    local n lo hi
    n=$1
    lo=$2
    hi=$3
    [[ $n -gt $lo ]] && [[ $n -lt $hi ]]
}

## withinbounds
# withinbounds {x => integer} {y => integer}
# returns true if 0 <= x,y < 20
function withinbounds() {
    local x y
    x=$1
    y=$2
    onebounds $x -1 20 && \
	onebounds $y -1 20
}

## randomize-map
# randomize-map {no args}
# goes through the whole array and sets each
#+ element to either $CHAR_ON or $CHAR_OFF,
#+ which are usually "x" and " ", respectively
function randomize-map() {
    local x y randchar
    for((y=0;y<20;y++)); do
	for((x=0;x<20;x++)); do
	    if (($RANDOM % 2 == 0)); then
		randchar=$CHAR_ON
	    else
		randchar=$CHAR_OFF
	    fi
            index golmap[$x,$y]= "$randchar"
	done
    done
}

## initialize-directions
# initialize-directions {no args}
# sets the direction array to a list of
#+ x and y directions, separated by commas
#+ for use with checking for neighbors
function initialize-directions() {
    dirs=( -1,-1 0,-1 1,-1 1,0 1,1 0,1 -1,1 -1,0 )
}

## init
# init {no args}
# sets up the graphics and a way to ensure that
#+ everything gets cleaned up at the end, as well
#+ as making the initial map and directions array
function init() {
    initgraphics
    echoat 4 4 "Ctrl-C to stop"
    trap "cleanup; exit" SIGINT SIGTERM
    randomize-map
    initialize-directions
}

function update() {
    
}

function main {
    golmap=( $(create-array 20,20) )
    declare -a dirs
    init
    while true; do
	update
	display
    done
    cleanup
}

lastsize=$(tput cols)$(tput lines)

while true; do
    for((y=0;y<20;y++)); do
        for((x=0;x<20;x++)); do
            total=0
            for((i=0;i<8;i++)); do
                newx=$(($x + ${xdir[i]}))
                newy=$(($y + ${ydir[i]}))
                if withinbounds $newx $newy; then
                    tmp=${golmap[$(($newy * 20 + $newx))]}
                    if [ $tmp = 1 ] || [ $tmp = 3 ] || [ $tmp = 5 ]; then
                        ((total++))
                    fi
                fi
            done
            if [ $total = 3 ]; then
                ((golmap[$(($x + $y * 20))] += 4))
            else
                if [ $total = 2 ] && [ ${golmap[$(($x + $y * 20))]} = 1 ]; then
                    ((golmap[$(($x + $y * 20))] += 4))
                else
                    ((golmap[$(($x + $y * 20))] += 2))
                fi
            fi
        done
    done

    cursize=$(tput cols)$(tput lines)
    [ $cursize = $lastsize ] || clear
    lastsize=$cursize
    echoat 0 0
    for((y=0;y<20;y++)); do
        for((x=0;x<20;x++)); do
            loc=$(($x + $y * 20))
            if [ ${golmap[$loc]} -gt 3 ]; then
                echo -n 'X'
                golmap[$loc]=1
            else
                echo -n ' '
                golmap[$loc]=0
            fi
        done
        echo '|'
    done
    echo $(x - 20)+
done
