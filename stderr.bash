#!/bin/bash

function stderr() {
    echo STDERR >&2
}

function stdout() {
    echo STDOUT
}

function both() {
    stderr
    stdout
}

cat <(both 2>&1)
