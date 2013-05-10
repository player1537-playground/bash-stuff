#!/bin/bash

WORK=$PWD/work
LOCKDIR=$WORK/lock

function init() {
    mkdir -p $LOCKDIR
}

function get-caller() {
    local caller
    caller=${FUNCNAME[1]}
}

function SPAWN() {
    local threadid funname lock md5
    threadid=$1; shift
    funname=$1; shift
    lock=$LOCKDIR/lock-$threadid
    pid=$LOCKDIR/pid-$threadid
    >$lock
    { $funname "$@"; echo 1 >>$lock; } &
    echo $! > $pid
    echo start-$threadid
}

function JOIN {
    local threadid pid lock
    threadid=$1; shift
    lock=$LOCKDIR/lock-$threadid
    pid=$LOCKDIR/pid-$threadid
    tail -f $lock --pid $(cat $pid) | read
    echo fin-$threadid
}

function _() {
    local dowhat varname
    dowhat=$1; shift
    case $dowhat in
	*++)
	    varname=${dowhat%++}
	    echo 1 >> $LOCKDIR/var-$varname
	    ;;
	*--)
	    varname=${dowhat%--}
	    echo -1 >> $LOCKDIR/var-$varname
	    ;;
	append)
	    
}

function foo() {
    local id
    id=$1
    echo $id
    sleep 5s
    echo $id-2
    sleep 2s
}

function bar() {
    echo GOIN\' FAST
}

function main {

}

init
main
