#!/bin/bash

function init() {
    stty -echo -icanon time 0 min 0
    echo -ne "\E[?25l"
    clear
}    

function readchar() {
    dd bs=1 count=1 2>/dev/null
}

function echoat() {
    thisx="$1"
    thisy="$2"
    thismsg="$3"
    echo -ne "\033[$thisy;$thisx""H$thismsg"
}

function sprite() {
    thisx="$1"
    thisy="$2"
    thisw="$3"
    echo -ne "\033[$thisy;$thisx""H"
    sed -e "s/.*/&\x1b[${thisw}D\x1b[1B/" | tr -d "\n"
}   

function x() {
    tmp=$(printf "%${2}s" " ")
    tmp="${tmp// /$1}"
    echo "$tmp"
}

function rect() {
    thisx="$1"
    thisy="$2"
    thisw="$3"
    thish="$4"
    thismsg="$(x "$5" $thisw)"
    echo -ne "\033[${thisy};${thisx}H"
    for((;thish>0;thish--)); do
	echo -ne "${thismsg}\033[1B\033[${thisw}D"
    done
}

function end() {
    stty sane
    echo -ne "\E[?25h"
    clear
}

init
x=1
y=10
oldx=$x
oldy=$y
vely=0
while true; do
    if [ ! $oldx = $x ] || [ ! $oldy = $y ]; then
	rect $oldx $oldy 8 8 " "
    fi
    oldx=$x
    oldy=$y
    key=$(readchar)
    case $key in
	w) ((vely -= 5));;
	a) ((x--));;
	d) ((x++));;
	q) break;;
    esac
    ((y += vely))
    if [ $vely -lt 0 ]; then
	((vely++))
    fi
    if [ $y -lt 20 ]; then
	if [ $y -gt 0 ]; then
	    ((vely++))
	else
	    y=1
	    vely=0
	fi
    else
	vely=0
    fi
    sprite $x $y 8 <<EOF
X  XX  X
X  XX  X
XX XX XX
XXX  XXX
 XXXXXX 
EOF
done
end
