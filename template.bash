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






OUTPUTDIR=$PWD/output
DEBUG=${DEBUG:-0}

function template() {
    local file line code codeprefix codesuffix pre suf var insidevar
    file=${1?-Pass a file}
    codeprefix="{%"
    codesuffix="%}"
    varprefix="{{"
    varsuffix="}}"
    equalprefix="{="
    equalsuffix="=}"
    insidevar=0
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
	elif expr "$line" : ".*${equalprefix}${equalsuffix}" &>/dev/null; then
	    #echo "EOF"
	    echo ")"
	    insidevar=0
	elif expr "$line" : ".*${equalprefix}.*${equalsuffix}" &>/dev/null; then
	    # {= VAR =}                     VAR=$(cat <EOF
	    # rawr rawr rawr rawr rawr      rawr rawr rawr rawr rawr
	    # {==}                          EOF
	    #                               )
	    #pre=${line%%$codeprefix*}
	    #suf=${line##*$codesuffix}
	    #var=${line##*$codeprefix}
	    #var=${var%%$codesuffix*}
	    var=$(expr "$line" : ".*${equalprefix}[ \t]*\([^ \t]*\)[ \t]*${equalsuffix}")
	    echo "$var=\$("
	    insidevar=1
	#elif [[ $insidevar == 1 ]]; then
	 #   echo "$line"
	else
	    printf "%s\n" "cat <<MOREEOF" "$line" "MOREEOF"
	fi
    done <$file
}

function include() {
    local file output
    file=${1?-Error, pass a file to include}
    output=$(template "$file")
    if [[ $DEBUG == 1 ]]; then
	echo "$output" >&2
    fi
    eval "$output"
}    

function main {
    local file output
    if [[ $# > 1 ]]; then
	output=$OUTPUTDIR/$1; shift
	mkdir -p ${output%/*}
    else
	output=/dev/stdout
    fi
    file=$1
    include "$file" > $output
}

main "$@"