#!/bin/bash

width=$(tput cols)
height=$(tput lines)

paddlewidth=10
paddle=$(($width / 2))
x=$(($paddle + $paddlewidth / 2))
y=$(($height - 2))
xinc=1
yinc=1
right=0

inc=2
largeinc=10

initgraphics

while true; do
    key=$(readchar)
    case $key in
        a) right=-$largeinc;;
        s) right=-$inc;;
        d) right=$inc;;
        f) right=$largeinc;;
        q) endgraphics
            exit;;
    esac
    if [ ! $right = 0 ]; then
        echoat $paddle $height "$(x ' ' $paddlewidth)"
        if [ $right -gt 0 ]; then
            ((paddle++))
            ((right--))
            if [ $(($paddle + $paddlewidth)) -gt $width ]; then
                paddle=$(($width - $paddlewidth))
            fi
        else
            ((paddle--))
            ((right++))
            if [ $paddle -lt 0 ]; then
                paddle=0
            fi
        fi
    fi
    echoat $paddle $height $(x = $paddlewidth)
done