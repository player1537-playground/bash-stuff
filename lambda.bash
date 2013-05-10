#!/bin/bash

WORK=$PWD/work

function init() {
    mkdir -p $WORK
}

function parseLambda() {
    local str args body
    str=$1
    args=${str%%.*}
    
}

function main() {
    
}

main "$@"