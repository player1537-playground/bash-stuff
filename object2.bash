#!/bin/bash

LAMBDA=0

function init() {
    :
}

# code passed through enviornment
# declare -a code
function @eval() {
    local IFS
    IFS=$'\n'
    eval "${code[*]}"
}

# code passed through environment
# declare -a code
function @lambda() {
    (( LAMBDA += 1 ))
    code=(
	"function lambda$LAMBDA() {"
	"${code[@]}"
	"}"
    )
    @eval
}

function @last-lambda() {
    echo lambda$LAMBDA
}

function def-class() {
    local class code
    class=$1
    code=(
	"function $class() {"
	"instantiate-object $class "'"$@"'
	"}"
    )
    @eval
}

function instantiate-object() {
    local class variable code
    class=$1
    variable=${2#$}
    code=(
	"@call $class "'"$@"'
    )
    @lambda
    code=(
	"$variable=$(@last-lambda)"
    )
    @eval
}

function @call() {
    local class what arg line this fun
    class=$1; shift
    what=$1; shift
    fun=$class@$what
    if declare -F $fun &>/dev/null; then
	for arg; do
	    if [[ $arg =~ [a-zA-Z]+:.+ ]]; then
		code=(
		    "${arg%%:*}=${arg#*:}"
		)
		@eval
	    else
		echo "Argument '$arg' to $fun not formatted like param:\"value\"" >&2
	    fi
	done
	this=${FUNCNAME[1]}
	$fun
    else
	echo "Method '$what' not defined on $class" >&2
    fi
}

function @var() {
    local code var class
    var=${1#$}
    class=$this-$var
    if ! declare -F $class &>/dev/null; then
	code=(
	    "function $class@set() {"
	    'code=('
	    '   "function '"$class@get"'() {"'
	    '   "echo $value" '
	    '   "}" '
	    ')'
	    '@eval'
	    "}"
	)
	code+=(
	    "function $class@get() {"
	    "echo \$default"
	    "}"
	)
	code+=(
	    "function $class() {"
	    "@call $class "'$@'
	    "}"
	)
	@eval
	
    fi
    code=(
	"$var=$class"
    )
    @eval
}

function Animal@speak() (
    $this greet what:world
)
function Animal@greet() (
    echo "Hello $what"
)
def-class Animal

function Math@add() (
    echo $(($x + $y))
)
function Math@sub() (
    echo $(($x - $y))
)
def-class Math

function Counter@count() {
    @var \$counterValue
    $counterValue set value:"$(($($counterValue get default:0) + 1))"
    $counterValue get default:-1
}
def-class Counter

function main {
    local animal
    Animal \$animal
    $animal test		## Method 'test' not defined on Animal
    $animal greet what:America	## Hello America
    $animal speak		## Hello world
    
    local math
    Math \$math
    $math add x:3 y:9		## 12
    $math sub x:5 y:2		## 3

    local counter
    Counter \$counter
    $counter count		## 1
    $counter count		## 2
    $counter count		## 3

    local counter2
    Counter \$counter2
    $counter2 count		## 1
    $counter2 count		## 2
    $counter2 count		## 3
}

main "$@"