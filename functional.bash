#!/bin/bash

function map() (
    local fun arrayname val tmp
    fun=$1
    arrayname=$2
    tmp=$arrayname[@]
    for val in "${!tmp}"; do
	$fun "$val"
    done
)

function reduce() {
    local fun arrayname accum default val tmp
    fun=$1
    arrayname=$2
    default=$3
    accum=$default
    tmp=$arrayname[@]
    for val in "${!tmp}"; do
	accum=$($fun "$accum" "$val")
    done
    echo "$accum"
}

function test-map() (
    function foo() {
	echo $1 :: $(($1 * $1))
    }
    a=( 3 4 5 6 7 8 )
    map foo a
)

test-map

function test-reduce() (
    function foo() {
	echo $(($1 + $2))
    }
    a=( 0 1 2 3 4 5 )
    reduce foo a 0
)

test-reduce
