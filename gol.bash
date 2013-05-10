#!/bin/bash

function initgraphics() {
    stty -echo -icanon time 0 min 0
}

function echoat() {
    thisx="$1"
    thisy="$2"
    thismsg="$3"
    echo -ne "\033[$thisy;$thisx""H$thismsg"
}

function endgraphics() {
    stty sane
}

## ################
## @param $1 x
## @param $2 y
## ################
## Checks if x and y are within 0<=?<20
function withinbounds() {
    local x=$1
    local y=$2
    if [ $x -gt -1 ] && [ $x -lt 20 ] && [ $y -gt -1 ] && [ $y -lt 20 ]; then
        return 0
    else
        return 1
    fi
}

xdir=( -1 0 1 1 1 0 -1 -1 )
ydir=( -1 -1 -1 0 1 1 1 0 )
declare -a golmap
initgraphics
echoat 4 4 "Ctrl-C to stop"
trap "endgraphics; exit" SIGINT SIGTERM
lastsize=$(tput cols)$(tput lines)

for((y=0;y<20;y++)); do
    for((x=0;x<20;x++)); do
        golmap[$(($x + $y * 20))]=$(($RANDOM % 2))
    done
done

while true; do
    if true; then
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
    fi
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
