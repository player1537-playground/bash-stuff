#!/bin/bash

function init() {
    stty -echo -icanon time 0 min 0
    echo -ne "\E[?25l"
    clear
    for((i=0;i<40;i++)); do
	echoat 40 $i "x"
	echoat $i 40 "x"
    done
}    

function readchar() {
    dd bs=1 count=1 2>/dev/null
}

function randapple() {
    x=$(($RANDOM % 39 + 1))
    y=$(($RANDOM % 39 + 1))
    echo "$x $y"
}

function echoat() {
    thisx="$1"
    thisy="$2"
    thismsg="$3"
    echo -ne "\033[$thisy;$thisx""H$thismsg"
}

function end() {
    stty sane
    echo -ne "\E[?25h"
    clear
}

init
snakex=( 1 1 1 1 )
snakey=( 1 2 3 4 )
x=1
y=5
apple="$(randapple)"
snakelen=3
score=0
dirsx=( 1 0 -1 0 )
dirsy=( 0 1 0 -1 )
dir=0
while true; do
    echoat $apple "A"
    echoat 42 5 "Score: $score"
    echoat ${snakex[0]} ${snakey[0]} " "
    for i in $(seq 0 $(($snakelen - 1))); do
	if [ $x = ${snakex[i]} ] && [ $y = ${snakey[i]} ]; then
	    break 2;
	fi
	snakex[$i]=${snakex[$(($i + 1))]}
	snakey[$i]=${snakey[$(($i + 1))]}
    done
    snakex[snakelen]=$x
    snakey[snakelen]=$y
    ((x=x+${dirsx[dir]}))
    ((y=y+${dirsy[dir]}))
    key=$(readchar)
    case $key in
	q) break;;
	d) ((dir++));;
	p) while [ ! "$(readchar)" = "p" ]; do true; done;;
	a) ((dir--));;
	*);;
    esac
    if [ $dir -gt 3 ] || [ $dir -lt 0 ]; then
	((dir=(dir+4)%4))
    fi
    if [ $x -lt 1 ] || [ $x -gt 39 ] || [ $y -lt 1 ] || [ $y -gt 39 ]; then
	break
    fi
    if [ "$x $y" = "$apple" ]; then
	((score++))
	((snakelen++))
	snakex[$snakelen]=${snakex[1]}
	snakey[$snakelen]=${snakey[1]}
	apple="$(randapple)"
    fi
    echoat $x $y "X"
    if [ $score -gt 5 ]; then
	if [ $score -gt 8 ]; then
	    sleep .07
	else
	    sleep .1$((4 - $(($score - 5)) / 2))
	fi
    else
	sleep .$((3 - $score / 2))
    fi
done    
end
echo "You scored: $score"
read -p "Play again? [y/N] "
if echo "$REPLY" | egrep "[Yy]" &>/dev/null; then
    exec "$0"
else
    echo "Thanks for playing!"
fi
