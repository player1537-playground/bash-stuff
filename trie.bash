#!/bin/bash

WORK=$PWD/work
TRIE=$WORK/trie

function init() {
    mkdir $TRIE
}

function addword() {
    local word first rest
    word=$1

    first=${word:1:1}
    rest=${word:2}
    
    if
    
    (
	mkdir -p $first
	cd $first
	addword $rest
    )
}

function 