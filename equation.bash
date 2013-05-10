#!/bin/bash -f

WORK=$PWD/work
TEMP=$WORK/equation-temp
declare -A VARS
declare -A TYPES
OPERS=(+ - / ^ \( \))
PROBLEM=
function init() {
    >$TEMP
}

function reset() {
    local problem_num
    problem_num=${1:-}
    VARS=()
    VARS[PI]="4*a(1)"
    VARS[RAD]="180/ PI "
    VARS[KILO]="1000"
    VARS[CENTI]="100"
    VARS[DECI]="10"
    VARS[MEGA]="1000000"
    TYPES=()
    PROBLEM=$problem_num
}

function separate-outputs() {
    echo
    echo
    echo
}

function definitions() {
    local line varname expression type varkey
    >$TEMP
    while true; do
	read line || exit
	if [[ $line = "" ]]; then
	    break
	fi
	echo "$line" >> $TEMP
	if [[ $line =~ ^#problem ]]; then
	    PROBLEM=${line#\#problem }
	fi
	if [[ ${line:0:1} = "#" ]]; then
	    continue
	fi
	type=
	if [[ $line =~ .*# ]]; then
	    type=${line#*#}
	    line=${line%#*}
	elif ! has-destructive-opers $line; then
	    for varkey in "${!VARS[@]}"; do
		if [[ ${line//$varkey/} != $line ]]; then
		    type=${TYPES[$varkey]}
		fi
	    done
	fi
	varname=${line%=*}
	expression=${line#*=}
	set-var "$varname" "$(spacify "$expression")" "$type"
    done 
    ./tablify.bash 3 25 25 25 <$TEMP
    echo
}

function spacify() {
    local line oper
    line=$1
    for oper in "${OPERS[@]}"; do
	line=${line//$oper/ $oper }
    done
    line=${line//\*/ \* }
    echo " $line "
}

function has-destructive-opers() {
    local line
    line=$1
    [[ -n ${line//[^\*\/]/} ]]
}

function has-opers() {
    local line
    line=$1
    for oper in "${OPERS[@]}"; do
	if [[ -n ${line//[^$oper]/} ]]; then
	    return 0
	fi
    done
    return 1
}

function get-var() {
    local var
    var=$1
    echo ${VARS[$var]}
}

function set-var() {
    local var val type
    var=$1
    val=$2
    type=$3
    VARS[$var]=$val
    TYPES[$var]=$type
}

function solve() {
    local line key newline type letter_index letters problem_id varname
    echo problem $PROBLEM
    letter_ind=0
    letters=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    while true; do
	read line || exit
	[[ $line = "" ]] && continue
	if [[ $line = "next" ]]; then
	    break
	fi
	if [[ ${line:0:1} = "#" ]]; then
	    eval "${line:1}"
	fi
	varname=$line
	if ! has-opers $line; then
	    type=${TYPES[$line]}
	else
	    type=${line#*#}
	    line=${line%#*}
	fi
	line=$(spacify "$line")
	while [[ "$prevline" != "$line" ]]; do
	    prevline=$line
	    for key in ${!VARS[@]}; do
		line=${line// $key / ( $(get-var $key) ) }
	    done
	done
	problem_id=$PROBLEM${letters[letter_index]}
	echo "$problem_id"
	echo "$varname="
	echo "$(echo "scale=5; $line" | bc -l)" "$type"
	echo "${line// /}"
	((letter_index++))
    done | do-table
}

function do-table() {
    ./tablify.bash 4 3 10 20 50
}

function process() {
    local problem_num
    problem_num=$1
    while true; do
	reset $problem_num
	separate-outputs
	definitions
	solve
    done
}

function main {
    local file skipto
    file=$1
    skipto=$2
    init
    if [[ -n "$file" ]]; then
	exec <$file
    fi
    if [[ -n $skipto ]]; then
	PROBLEM=$skipto
	while true; do
	    read line || exit
	    [[ $line = "#problem $skipto" ]] && break
	done
    fi		
    process $skipto
}

main "$@"
