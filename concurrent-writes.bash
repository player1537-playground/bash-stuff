#!/bin/bash

WORK=$PWD/work
FILE=$WORK/concurrent-writes

function init() {
    mkdir -p $WORK
    >$FILE
}

function task() {
    local i x
    x=$1
    for((i=0;i<500;i++)); do
	echo $x >> $FILE
    done
}

function spawn-tasks() {
    local i
    for((i=0;i<10;i++)); do
	task $i &
    done
}

function main {
    spawn-tasks
    sleep 5s
    wc -l <$FILE
}

init
main "$@"
