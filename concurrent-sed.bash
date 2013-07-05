#!/bin/bash

FILE=$PWD/work/output-writes
>$FILE

function foo() {
    local i
    for i in {1..500}; do
	echo $i >> $FILE
	sleep 0.01s
    done
}

function bar() {
    local i
    for i in {1..100}; do
	sed $FILE -i -e '1d'
    done
}

foo &
bar
wc -l $FILE