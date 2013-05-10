#!/bin/bash

function main() {
    local rules starting current rulekey iterations temp LANG
    LANG=c
    declare -A rules
    for arg; do
	case do$arg in
	    do*\=*) rules[${arg%=*}]=${arg#*=};;
	    do-n*) iterations=${arg#-n};;
	    do*) starting=$arg;;
	esac
    done
    current=$starting
    echo $current
    while (((iterations-=(iterations != -1)) != 0)); do
	echo -n [
	for rulekey in ${!rules[@]}; do
	    echo -n $rulekey,
	    temp=${rules[$rulekey]}
	    current=${current//$rulekey/${temp^^}}
	done
	echo ]
	current=${current,,}
	echo $current
	if [ ${iterations:0:1} = - ]; then
	    sleep ${iterations:1}
	fi
    done
}

main "$@"