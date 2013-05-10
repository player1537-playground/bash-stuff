#!/bin/bash

COLUMNS=$1; shift
COLUMN_LENGTHS=("$@")

function line-length() {
    local line len
    line=$1
    len=$2
    if [[ ${#line} -gt $len ]]; then
	line=${line:0:$len}
    else
	while [[ ${#line} -lt $len ]]; do
	    line+=" "
	done
    fi
    echo "$line"
}

function main {
    local line_ cur_col
    cur_col=0
    while true; do
	read line_ || break
	if [[ $cur_col != 0 ]]; then
	    echo -n " | "
	fi
	echo -n "$(line-length "$line_" ${COLUMN_LENGTHS[$cur_col]})"
	((cur_col++))
	if [[ $cur_col = $COLUMNS ]]; then
	    echo
	    cur_col=0
	fi
    done
    if [[ $cur_col != 0 ]]; then
	echo
    fi
}

main "$@"