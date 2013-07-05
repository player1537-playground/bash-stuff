#!/bin/bash

## op-add
#` op-add n1 n2 n3 ...
# Adds up the arguments, or returns 0 if
#+ none are passed.
function op-add() {
    local val sum
    declare -i sum
    sum=0
    for val; do
	((sum += $val))
    done
    echo $sum
}

## op-mul
#` op-mul n1 n2 n3 ...
# Multiplies arguments, defaults to 1.
function op-mul() {
    local val prod
    declare -i prod
    prod=1
    for val; do
	((prod *= $val))
    done
    echo $prod
}

## op-div
#` op-div n1 n2 n3 ...
# Divides the arguments ((n1 / n2) / n3) / ...
#+ defaults to 1.
function op-div() {
    local val quot
    declare -i quot
    quot=1
    for val; do
	((quot /= $val))
    done
    echo $quot
}

## op-sub
#` op-sub n1 n2 n3 ...
# Subtracts arguments ((n1 - n2) - n3) - ...
#+ defaults to 0.
function op-sub() {
    local val ret
    declare -i ret
    ret=0
    for val; do
	((ret -= $val))
    done
    echo $ret
}

