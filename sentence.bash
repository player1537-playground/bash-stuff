#!/bin/bash

function sentence() {
    sent$((1 + $RANDOM % $(egrep "function sent[0-9]+" "$0" | wc -l))) | sed -ne '1 { s/^./\U&/ }; H; $ { x; s/\n/ /g; s/^ //; s/$/./; p; }'
}

# [robot thing] is [adverb] [completionstatus]
function sent1() {
    robotthing
    is
    adverb
    completionstatus
}

# [newness] [designlikething] for the [designedthing] [comingsoonstatus]
function sent2() {
    newness
    designlikething
    echo "for the"
    designedthing
    echo "coming"
    comingsoonstatus
}

newness() {
    choose new old
}

designlikething() {
    choose design idea theme
}

designedthing() {
    choose website chassis twitter facebook pit
}

comingsoonstatus() {
    choose soon later never "in a while" "to a team near you"
}

robotthing() {
    choose chassis "drive train" "vision tracking"
}

is() {
    choose is
}

adverb() {
    choose finally stupidly
}

completionstatus() {
    choose finished broken destroyed started 
}

function choose() {
    local n chosen
    n=0
    while [ ! $# = 0 ]; do
	((n++))
	if [ $(($RANDOM % n)) = 0 ]; then
	    chosen=$1
	fi
	shift
    done
    echo $chosen
}

function main() {
    sentence
}

main "$@"