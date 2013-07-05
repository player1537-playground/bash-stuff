#!/bin/bash

WORK=$PWD/work
OUTQUEUE=$WORK/queue.fifo
THREAD_PID=

function init() {
    mkdir -p $WORK
    rm -f $OUTQUEUE
    mkfifo $OUTQUEUE
    trap "cleanup; exit" SIGINT SIGTERM SIGQUIT
}

function spawn_threads() {
    exec 5<> <( echo INITIAL )
    exec 6< <( read_inputs )
    exec 7< <( thread_output )
}

function read_inputs() {
    function line
    while true; do 
	read line || break
	

## thread_output
# thread_output {args from scope}
# This function does most of the work for the program
function thread_output() {
    local line
    while true; do
	read line || break
	
}

## smooth-output.bash
# smooth-output.bash normal_time output_len max_time
# This assumes that the output is some sort of cyclical
#+ array, where the addition of one items moves everything 
#+ back by one, and removes the first itme.
#+ ie, if A = [a,b,c,d], adding e causes it to be [b,c,d,e]
# normal_time is the length of time you want each item to 
#+ appear on the output list.  If n is the length, then
#+ normally, there will be an normal_time/n delay between
#+ each new output.  output_len is the length of the cyclical
#+ list, [a,b,c,d] has 4 elements, so output_len would be 4.
#+ Finally, max_time is the amount of time it takes for some
#+ piece of information to become useless, and the program
#+ will account for that so that none of the information 
#+ becomes irrelevant (though it might be output for only a
#+ very short time).
function main {
    local normal_time output_len max_time
    normal_time=$1
    output_len=$2
    max_time=$3
    init
    spawn_threads
    cleanup
}

main "$@"