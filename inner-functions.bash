#!/bin/bash

function outer() {
    eval "function $1() {
	echo \"\$@\"
    }"
}

outer testing
declare -f
testing 1 2 3 