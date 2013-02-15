#!/bin/bash

source objects.bash

function main() {
    echo Inside Main example
    new_class LinkedList <<'EOF'
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
EOF
  echo LinkedList Created
    new_class Action <<'EOF'
function init():

function act(value):
echo $value
EOF
    echo Action created
    sub_class Action Square <<'EOF'
function act(value):
echo $(($value * $value))
EOF
    echo Square created
    sub_class Action Print <<'EOF'
function act(value):
echo $value >&2
EOF
    echo Print created
    new_class IntegerGenerator <<'EOF'
function init():

function getList(max=10):
declare -i cur=0
head=$(allocate_object LinkedList)
while [ $cur -lt $max ]; do
  call_method $head append $cur
  ((cur++))
done
call_method $head getNext
EOF
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
main "$@"