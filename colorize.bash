#!/bin/bash

function color() {
    declare -A colors
    colors[Black]='\033[0;30m'
    colors[DarkGray]='\033[1;30m'
    colors[Blue]='\033[0;34m'
    colors[LightBlue]='\033[1;34m'
    colors[Green]='\033[0;32m'
    colors[LightGreen]='\033[1;32m'
    colors[Cyan]='\033[0;36m'
    colors[LightCyan]='\033[1;36m'
    colors[Red]='\033[0;31m'
    colors[LightRed]='\033[1;31m'
    colors[Purple]='\033[0;35m'
    colors[LightPurple]='\033[1;35m'
    colors[Brown]='\033[0;33m'
    colors[Yellow]='\033[1;33m'
    colors[LightGray]='\033[0;37m'
    colors[White]='\033[1;37m'
    colors[None]='\033[0m'
    colors[Underline]='\033[4m'

    possible_colors=( Blue LightBlue Green LightGreen Cyan LightCyan \
	Red LightRed Purple LightPurple Brown Yellow LightGray )
    sum=$(sum <(echo "$@"))
    sum=${sum%% *}
    sum=$(expr "$sum" : "^0*\(.*\)")
    (( sum %= ${#possible_colors[@]} ))
    colorname=${possible_colors[$sum]}
    echo -e "${colors[$colorname]}$@${colors[None]}"
}

