#!/bin/bash -x

STACK_OFFSET=1
STACK_POINTER=0
INITIAL_INDEX=0

function create-stack() {
    local ret
    ret=( $INITIAL_INDEX )
    echo "${ret[@]}"
}

function get-index() {
    local _array _ind
    _array=$1
    _ind=$2
    echo $(($_ind + $STACK_OFFSET))
}

function push-stack() {
    local _array _ind _vals _tmp
    _array=$1; shift
    _vals="$@"
    _tmp=$_array[$STACK_POINTER]
    _ind=${!_tmp}
    echo $_ind
    eval $_array[$(get-index $_array $_ind)]=\$_vals
    eval $_array[$STACK_POINTER]=$(($_ind + 1))
}

function pop-stack() {
    local _array _ind _
    _array=$1
    _tmp=$_array[$STACK_POINTER]
    _ind=${!_tmp}
    _ind=$(($_ind - 1))
    if [[ $_ind -gt -1 ]]; then
	_tmp=$_array[$(get-index $_array $_ind)]
	echo ${!_tmp}
	eval $_tmp=
	eval $_array[$STACK_POINTER]=$(($_ind - 1))
    else
	echo Popping an empty stack >&2
	return 1
    fi
}

function is-empty() {
    local _array _ind _tmp
    _array=$1
    _tmp=$_array[$STACK_POINTER]
    [[ ${!_tmp} == 0 ]]
}

S=$(create-stack)
push-stack S rawr
push-stack S meow
push-stack S [two words yolo]
echo "${S[@]}"
pop-stack S
pop-stack S
echo "${S[@]}"
