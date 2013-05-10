#!/bin/bash

source sorcerer.bash

function compose() {
    local f g name
    f=$1; shift
    g=$1; shift
    name=comp-$f-$g
    declare -f $name
    eval 'function '"$name"'() {
	$f $($g "$@")
    }'
    echo $name
}

function iterated() {
    local f n
    # f^n($@)
    f=$1; shift
    n=$1; shift
    if [ $n = 0 ]; then
	echo "$@"
    else
	((n--))
	$f $(iterated $f $n "$@")
    fi
}

if ! was_sourced; then

    function foo() {
	local arg
	for arg; do
	    echo $(($arg + 1))
	done
    }

    function bar() {
	local arg
	for arg; do
	    echo $(($arg - 1))
	done
    }

    #$(compose foo bar) 4
 
    #echo $(compose bar foo 4) = $(bar $(foo 4))

    #echo $(compose foo foo 1) = $(foo $(foo 1))

    echo $(iterated foo 3 6 7 8) = $(foo $(foo $(foo 6 7 8)))

fi