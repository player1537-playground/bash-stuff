#!/bin/bash

MASTER_PORT=8888
SLAVE_PORT_START=$(($MASTER_PORT+1))
WORK=$PWD/work
CLIENTS=$WORK/clients
MY_WORKLOAD=$WORK/my_workload
WORK_LOAD=

function init() {
    rm -rf $CLIENTS
    mkdir -p $CLIENTS
}

function master() {
    until nc -l $MASTER_PORT | handle-client; do
	echo Getting another client
    done
}

function handle-client() {
    local IFS name host port 
    IFS=$'\t'
    read name host port
    echo $host $port > $CLIENTS/$(ls $CLIENTS | wc -l)
    reply $host $port &
}

function reply() {
    local host port
    host=$1
    port=$2
    cat $WORK_LOAD | nc $host $port
}

function connect() {
    local serverhost my_host my_port
    serverhost=$1
    my_host=$2
    my_port=$3
    {
	until nc -l $my_port >$MY_WORKLOAD/.$my_port; do
	    mv .$my_port $my_port
	    echo getting more work
	done
    } &
    echo $my_host $my_port | nc $serverhost $MASTER_PORT
}

function listen-for-workload() {
    