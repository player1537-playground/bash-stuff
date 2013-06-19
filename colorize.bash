#!/bin/bash

# `declare -A colors` is passed by scope 
function color-initialize-array() {
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
}

## color
# color color_name {$@ text}
# draws the text in the specified color
function color() {
    local color text
    color=$1; shift
    text="$@"
    if [[ -z $text ]]; then
	echo "Probably forgot to change the function to colorize"
	return
    fi
    declare -A colors
    color-initialize-array
    echo -e "${colors[$color]}$text${colors[None]}"
}

## colorize
# colorize {$@ text}
# draws the text in some "random", but consistent color based on the
#+ contents of the text.
function colorize() {
    declare -A colors
    color-initialize-array
    possible_colors=( Blue LightBlue Green LightGreen Cyan LightCyan \
	Red LightRed Purple LightPurple Brown Yellow )
    sum=$(sum <(echo "$@"))
    sum=${sum%% *}
    sum=$(expr "$sum" : "^0*\(.*\)")
    (( sum %= ${#possible_colors[@]} ))
    colorname=${possible_colors[$sum]}
    echo -e "${colors[$colorname]}$@${colors[None]}"
}

## color-dir
# color-dir path/to/dir
# draws each part of the argument (separated by slashes) in a color
#+ specified by colorize
function color-dir() { 
    local IFS inputdir dirs dir first
    inputdir=$1
    first=1
    IFS=/ dirs=( $inputdir )
    for dir in "${dirs[@]}"; do 
	if [[ $first != 1 ]]; then
	    echo -n /
	fi
	echo -n "$(colorize $dir)"
	first=0
    done
    echo
}
