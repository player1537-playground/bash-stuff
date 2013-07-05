#!/bin/bash

NUM_CHILDREN=2
# TREE=( [X] [XA XB] [AC AD BE BF] [CG CH DI DJ EK EL FM FN] )
# TREE=( [X] [XA XB] [XAC XAD XBE XBF] [XACG XACH XADI XADJ XBEK XBEL XBFM XBFN] )
# TREE=( [0] [0L 0R] [0LL 0LR 0RL 0RR] [0LLL 0LLR 0LRL 0LRR 0RLL 0RLR 0RRL 0RRR] )
# TREE=( [0] [00 01] [000 001 010 011] )
# [[0LLL 0LL 0LLR] 0L [0LRL 0LR 0LRR]] 0 [[0RLL 0RL 0RLR] 0R [0RRL 0RR 0RRR]]
# 0's left child: 2*0+0, right: 2*0+1
# 0L's left: 2*(2*0+0)+0, right: 2*(2*0+0)+1
# 0R's left: 2*(2*0+1)+0, right: 2*(2*0+1)+1

function get-level-length() {
    local n
    n=$1
    echo $((2 ** $n))
}

function get-first-index() {
    local n calculated
    n=$1
    calculated=$(($NUM_CHILDREN ** $n - 1))
    echo $calculated
}

# dirs ~= 0110 for 0RRL
# 13 - 7 = 6, 0110b = 6
# index = $(binary-to-decimal $dirs) + $(get-first-index $((${#dirs} - 1)))
function get-real-index() {
    local dirs index level
    declare -i index
    declare -i level
    dirs=$1
    index=0
    level=0
    while [[ -n $dirs ]]; do
	level+=1
	case $dirs in
	    0*) level+=-1;;
	    L*) index=$(left $index);;
	    R*) index=$(right $index);;
	esac
	dirs=${dirs#?}
    done
    index+=$(get-first-index $level)
    echo $index
}

function left() {
    local n
    n=$1
    echo $(($NUM_CHILDREN * $n + 0))
}

function right() {
    local n
    n=$1
    echo $(($NUM_CHILDREN * $n + 1))
}

function insert-into-tree() {
    :
}

for n in {0..6}; do
    echo "$n $(get-level-length $n) $(get-first-index $n)"
    # [0,1) [1,3) [3,7) [7,15)
    # [0,0] [1,2] [3,6] [7,14]
    # [2**n-1,2**(n+1)-2]
    # [2**0-1,2**1-1]
    # 0 1 0
    # 1 2 1
    # 2 4 3
    # 3 8 7
    # 4 16 15
    # 5 32 31
    # 6 64 63
done

for n in 0 0L 0R 0LL 0LR 0RL 0RR 0RRL; do
    get-real-index ${n#?}
done
