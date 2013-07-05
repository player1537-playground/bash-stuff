#!/bin/bash

## was_sourced
#` if was_sourced; then ...; fi
# Returns true if the current file was
#+ sourced and is being used like a 
#+ library instead of just a program.
function was_sourced() {
    [ $0 = bash ]
}

