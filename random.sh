#!/bin/bash

NUM_CASES=400
RANDOM_NUM=out.random
NUM_RETRIES=50

function regexp_() {
    local n=$1
    echo /$n/w _$n
}

function regexp() {
    local i
    for((i=0;i<10;i++)); do
	regexp_ $i
    done
    echo d
}

function random() {
    local i
    for((i=0;i<NUM_CASES;i++)); do
	echo $RANDOM
    done
}

function runonce() {
    local file num total lines
    random > $RANDOM_NUM
    sed $RANDOM_NUM -e "$(regexp)"
    total=$(cat _* | wc -l)
    for file in _*; do
	num=${file#_}
	lines=$(wc -l<$file)
	echo "$num: $(($lines * 100 / $total))% "
    done
}

function main() {
    
    sed -ne '/^0/! d; /^0/ { s/.* \([0-9]*\)%/\1/; H; }; p'
}

runonce "$@"
