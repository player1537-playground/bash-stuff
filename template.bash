#!/bin/bash

function template() {
    local file line code codeprefix codesuffix pre suf var
    file=$1
    codeprefix="{%"
    codesuffix="%}"
    varprefix="{{"
    varsuffix="}}"
    while true; do
	read line || break
	line=$(expr "$line" : "^[ \t]*\(.*\)[ \t]*$")
	if [[ $line =~ ^[\ \\t]*# ]]; then
	    continue
	elif expr "$line" : ".*${varprefix}.*${varsuffix}" &>/dev/null; then
	    line=${line//$varprefix/}
	    line=${line//$varsuffix/}
	    echo "echo \"$line\""
	elif expr "$line" : ".*${codeprefix}.*${codesuffix}" &>/dev/null; then
	    pre=${line%%$codeprefix*}
	    suf=${line##*$codesuffix}
	    code=${line##*$codeprefix}
	    code=${code%%$codesuffix*}
	    [[ $pre ]] && echo "echo \"$pre\""
	    echo "$code"
	    [[ $suf ]] && echo "echo \"$suf\""
	else
	    echo "echo \"$line\""
	fi
    done <$file
}

function main {
    local file output
    file=${1?-Error, pass a file}
    output=$(template "$file")
    echo "$output" >&2
    eval "$output"
}

main "$@"