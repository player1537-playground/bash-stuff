#!/bin/bash

## x
#` x what num
# Echos $what $num times
function x() {
    local what num tmp
    what=$1
    num=$2
    printf -v tmp "%${num}s" " "
    tmp=${tmp// /$what}
    echo "$tmp"
}
