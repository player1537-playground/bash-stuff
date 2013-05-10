#!./objects-parser.bash

source objects.bash
init

function classes() {
    NEW_CLASS(Array)
    function init():
    mkdir values
    function get(index):
    cat values/index
    function set(index, value):
    echo $values > values/$index
    function map(BinaryFunction):
    for index in $(ls values/; do
	call_method $BinaryFunction act $index "$(cat values/$index)"
    done
}

function main {
    
}

classes
main