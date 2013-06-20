#!/bin/bash

# Givens:
# USER=SeaBass
# boolean=0
# +----------------------------------------+----------------------------------------+
# | Inputs                                 | Outputs                                |
# |                                        |                                        |
# +----------------------------------------+----------------------------------------+
# | Hello World                            | Hello World                            |
# |                                        |                                        |
# +----------------------------------------+----------------------------------------+
# | Hello {{ $USER }}!                     | Hello SeaBass!                         |
# |                                        |                                        |
# +----------------------------------------+----------------------------------------+
# | {% if [[ $boolean == 0 ]]; then %}     |                                        |
# | Nascar is awesome                      | Nascar is awesome                      |
# | {% fi %}                               |                                        |
# +----------------------------------------+----------------------------------------+
# | {% if [[ $USER == Jeoffrey ]]; then %} |                                        |
# | LabVIEW is my favorite language        |                                        |
# | {% fi %}                               |                                        |
# +----------------------------------------+----------------------------------------+
# | {% for color in F00 0F0 00F; do %}     | <font color="#F00">Rawr</font>         |
# | <font color="#{{ $color }}">Rawr</font>| <font color="#0F0">Rawr</font>         |
# | {% done %}                             | <font color="#00F">Rawr</font>         |
# +----------------------------------------+----------------------------------------+
# | {= MAGIC_STRING =}                     |                                        |
# | give us a perfect score                |                                        |
# | {==}                                   |                                        |
# | A good thing to keep in mind is to     | A good thing to keep in mind is to     |
# |  {{ $MAGIC_STRING }}!                  |  give us a perfect score!              |
# +----------------------------------------+----------------------------------------+
# | {% date +%Y %} is the year of Linux on | 2013 is the year of Linux on           |
# | the desktop!                           | the desktop!                           |
# +----------------------------------------+----------------------------------------+
# | {% include other-template.tpl %}       | <the contents of other-template.tpl,   |
# |                                        |  interpreted>                          |
# +----------------------------------------+----------------------------------------+

## KNOWN ISSUES
# You can't have more than one tag on each line.  I was lazy about that, but if 
#+ something just doesn't seem to be working... that's why.
# Using {{ and }}, if you put spaces between them and the variable inside, like
#+ {{ $var }}, then those spaces will be present in the output too.


OUTPUTDIR=${OUTPUTDIR:-$PWD/output}
DEBUG=${DEBUG:-0}
declare -i CURLEVEL
CURLEVEL=1

function template() {
    local file line code codeprefix codesuffix pre suf var insidevar whitepsace 
    file=${1?-Pass a file}
    codeprefix="{%"
    codesuffix="%}"
    varprefix="{{"
    varsuffix="}}"
    equalprefix="{="
    equalsuffix="=}"
    insidevar=0
    whitespace=$' \t'
    while true; do
	read -r line || break
	line=$(expr "$line" : "^[$whitespace]*\(.*\)[$whitespace]*$")
	if [[ $line =~ ^[\ \\t]*# ]]; then
	    continue
	elif expr "$line" : ".*${varprefix}.*${varsuffix}" &>/dev/null; then
	    # {{ $var }}
	    pre=${line%%$varprefix*}
	    suf=${line##*$varsuffix}
	    line=${line##*$varprefix}
	    line=${line%%$varsuffix*}
	    line=$(trim-whitespace "$line")
	    output-one-line "$pre$line$suf"
	elif expr "$line" : ".*${codeprefix}.*${codesuffix}" &>/dev/null; then
	    # {% code block %}
	    pre=${line%%$codeprefix*}
	    suf=${line##*$codesuffix}
	    code=${line##*$codeprefix}
	    code=${code%%$codesuffix*}
	    [[ $pre ]] && output-one-line "$pre"
	    echo "$code"
	    [[ $suf ]] && output-one-line "$suf"
	elif expr "$line" : ".*${equalprefix}${equalsuffix}" &>/dev/null; then
	    # {==}
	    echo ")"
	    insidevar=0
	elif expr "$line" : ".*${equalprefix}.*${equalsuffix}" &>/dev/null; then
	    # {= VAR =}                     VAR=$(
	    #                               cat <<EOF
	    # rawr rawr rawr rawr rawr      rawr rawr rawr rawr rawr
	    #                               EOF
	    # {==}                          )
	    var=$(expr "$line" : ".*${equalprefix}[$whitespace]*\([^$whitespace]*\)[$whitespace]*${equalsuffix}")
	    echo "export $var=\$("
	    insidevar=1
	else
	    output-one-line "$line"
	fi
    done <$file
}

function trim-whitespace() {
    local str oldstr whitespace
    whitespace=$' \t'
    str=$1
    oldstr=
    while [[ "$str" != "$oldstr" ]]; do
	oldstr=$str
	str=${str#[$whitespace]}
    done
    oldstr=
    while [[ "$str" != "$oldstr" ]]; do
	oldstr=$str
	str=${str%[$whitespace]}
    done
    echo "$str"
}

function output-one-line() {
    local line
    line=$1
    printf "%s\n" "cat <<MOREEOF${CURLEVEL}" "$line" "MOREEOF${CURLEVEL}"
}

function include() {
    local file output
    CURLEVEL+=1
    file=${1?-Error, pass a file to include}
    output=$(template "$file")
    if [[ $DEBUG == 1 ]]; then
	echo "$output" >&2
    fi
    file=./$file
    export SRC=${file%/*}
    SRC=${file/%*} eval "$output"
    CURLEVEL+=-1
}    


# main $outputfile $inputfile
# main $inputfile
function main {
    local file output
    if [[ -n $2 ]]; then
	output=$OUTPUTDIR/$1; shift
	mkdir -p ${output%/*}
    else
	output=/dev/stdout
    fi
    file=$1
    include "$file" | tr -d '' > $output
    # The `tr` is there because  was showing up in the compiled files, and this is the easiest fix:
    #+ remove all of them at the very end
}

main "$@"