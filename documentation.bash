#!/bin/bash

HALFTAB="  "
TAB=${HALFTAB}${HALFTAB}

## output-* note
# For each of these functions, variables are passed 
#+ as part of the current scope, and so we don't
#+ re-store it to another local variable.  This just
#+ makes things cleaner as a whole.

function output-header() {
    echo
    echo "[[ ${line^^} ]]"
}

function output-start-paragraph() {
    echo -e "${TAB}$line"
}

function output-continue-paragraph() {
    echo -e "${HALFTAB}$line"
}

function output-code() {
    echo -e "${TAB}$line"
}

function parse() {
    local full_line line type
    while true; do
	read -r full_line || break
	line=${full_line#* }
	type=${full_line%% *}
	case $type in
	    \#\#) output-header;;
	    \#) output-start-paragraph;;
	    \#+) output-continue-paragraph;;
	    \#\`) output-code;;
	esac
    done
}

function main() {
    local file
    file=${1:?Pass a file}
    parse <$file
}

main "$@"
