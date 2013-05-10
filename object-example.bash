#!/bin/bash objects-parser.bash

source objects.bash

function classes() {
    echo Inside Main example
    NEW_CLASS(LinkedList)
    function init(data=null,next=null):
    echo $data > data
    echo $next > next

    function getNext():
    cat next

    function getData():
    cat data

    function isEmpty():
    [ $(cat next) = null ]

    function setNext(next=null):
    echo $next > next

    function append(data):
    if call_method this isEmpty; then
	new=$(allocate_object LinkedList $data)
	call_method this setNext $new
    else
	call_method $(call_method this getNext) append $data
    fi

    function map(Action):
    head=$(allocate_object LinkedList)
    node=$(cat this)
    while ! call_method $node isEmpty; do
	call_method $head append $(call_method $Action act $(call_method this getData))
	node=$(call_method $node getNext)
    done
    call_method $head getNext

    function apply(Action):
    node=$(cat this)
    while ! call_method $node isEmpty; do
	call_method $Action act $(call_method this getData)
	node=$(call_method $node getNext)
    done
END_OF_CLASS
    

    
    echo LinkedList Created
    NEW_CLASS(Action)
    function init():

    function act(value):
    echo $value
END_OF_CLASS


    
    echo Action created
    SUB_CLASS(Action, Square)
    function act(value):
    echo $(($value * $value))
END_OF_CLASS

    
    echo Square created
    SUB_CLASS(Action, Print)
    function act(value):
    echo $value >&2
END_OF_CLASS



    echo Print created
    NEW_CLASS(IntegerGenerator)
    function init():

    function getList(max=10):
    declare -i cur=0
    head=$(allocate_object LinkedList)
    while [ $cur -lt $max ]; do
	call_method $head append $cur
	((cur++))
    done
    call_method $head getNext
END_OF_CLASS
}
    
function main {
    echo IntegerGenerator Created
    local square=$(allocate_object Square)
    echo Square fun allocated
    local intgen=$(allocate_object IntegerGenerator)
    echo IntegerGenerator fun allocated
    local print=$(allocate_object Print)
    echo Print fun allocated
    local intlist=$(call_method $intgen getList 10)
    echo Int List run
    local updatedList=$(call_method $intlist map $square)
    echo Updated List run
    call_method $updatedList apply $print
}

init
classes
main "$@"