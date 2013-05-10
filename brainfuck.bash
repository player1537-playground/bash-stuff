#!/bin/bash

WORK=$PWD/work
BF=$WORK/$BF
MEMEORY=$BF/memory
LOOP_STACK=$BF/loop-stack
NEXT=dir
GET=data
PC=

# >
function GT() {
    cd $NEXT
}

# <
function LT() {
   cd ..
}

# +
function P() {
    echo $((($(cat $GET) + 1) % 255)) > $GET
}

# -
function M() {
    echo $((($(cat $GET) + 254) % 255)) > $GET
}

# [
function LB() {
    mkdir -p $NEXT
    cd $NEXT
    echo 