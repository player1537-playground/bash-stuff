#!/bin/bash

function main {
    local file code IFS
    file=$1
    if diff <(sed "$file" -ne 's/.*##[ \t]*//p') <(bash "$file" 2>&1); then
	echo "Passed"
    else
	echo "Failed"
    fi
}

main "$@"