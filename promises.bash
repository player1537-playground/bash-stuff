#!/bin/bash

CURRENT_PROMISE=
PROMISE_PRE=promised-
SUCCESS_PRE=success-
FAILURE_PRE=failure-

## promise
# promise function args
# starts the promise specification, onsuccess,
#+ onfail, and run all operate on the same promise
#+ that is started here.  The general flow will
#+ look like:
#` promise foo-async-task arg1 arg2
#` onsuccess do-task-two arg1 arg2
#` onfail echo "Failure during async task"
#` promised-foo-async-task
function promise() {
    local funname args newname
    funname=$1; shift
    args="$@"
    CURRENT_PROMISE=$funname
    newname=$PROMISE_PRE$funname
    eval "function $newname() {
              {
                  $funname $args
              } && $SUCCESS_PRE$funname || $FAILURE_PRE$funname
          }"
}

function onsuccess() {
    local funname args newname
    funname=$1; shift
    args="$@"
    newname=$SUCCESS_PRE$CURRENT_PROMISE
    eval "function $newname() {
              $funname $args
          }"
}

function onfail() {
    local funname args newname
    funname=$1; shift
    args="$@"
    newname=$FAILURE_PRE$CURRENT_PROMISE
    eval "function $newname() {
              $funname $args
          }"    
}

promise sleep 5
onsuccess echo hooray
onfail echo booo
promised-sleep
