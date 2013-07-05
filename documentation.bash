#!/bin/bash

HALFTAB="  "
TAB=${HALFTAB}${HALFTAB}
ALL=

## documentation.bash
#` documentation.bash file.bash
# Parse file.bash and outputs the comments in a 
#+ more readable format to help developers using
#+ either the program or library. By default, 
#+ this program will only output exported 
#+ comments, which start with a "##" name. For
#+ example:
#` ## my-function-name
#+ will be exported always. To start a non-
#+ exported comment, use "#^" as in,
#` #^ non-exported
#+ Other than those, a single "#" will begin a
#+ paragraph in the comment, and a "#+" will
#+ continue one. As in:
#` # Start of the paragraph
#` #+ continuing it
#` #+ continuing some more
#+ Finally, to include code in the comments, use
#+ "#`" as in,
#` #` echo "This is some code"

#^ output-* note
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
    echo -e "${TAB}\$ $line"
}

function is-exported() {
    if [[ $ALL == 1 ]]; then
	return 0
    elif [[ $exported == 1 ]]; then
	return 0
    else
	return 1
    fi
}

function parse() {
    local full_line line type exported
    while true; do
	read -r full_line || break
	line=${full_line#* }
	type=${full_line%% *}
	case "$type" in
	    \#^) exported=0
		is-exported && output-header;;
	    \#\#) exported=1
		is-exported && output-header;;
	    \#) is-exported && output-start-paragraph;;
	    \#+) is-exported && output-continue-paragraph;;
	    \#\`) is-exported && output-code;;
	esac
    done
}

function main() {
    local file display_all
    file=${1:?Pass a file}
    display_all=$2
    case $display_all in
	ALL) ALL=1;;
	*) ALL=
    esac
    parse <$file
}

main "$@"
