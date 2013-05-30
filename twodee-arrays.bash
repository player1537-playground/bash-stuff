#!/bin/bash

## twodee-arrays.bash
# This is a library for use with GNU Bash with a version
#+ at least >= 4.1.5.  An example program is at the end of the
#+ file and shows how to create a multidimensional array and
#+ how to index it, both for setting and retrieving values,
#+ When creating the array, you can pass in a default value that
#+ the array will use if there is no element there.  This is
#+ helpful because, if you know most of the array will be one
#+ value, you won't have to set all of them and it will allow most
#+ of the array to be sparse.  Only the values that you explicitly
#+ set will use memory.
# Multidimensional arrays are stored using a standard array, but
#+ with the first few elements to keep track of the shape.  When
#+ you call one of the functions to manipulate them (really, there's
#+ only one: index) the array is passed by reference and evaluated 
#+ that way.  This does lead to a couple of problems, however.  If
#+ you array is actually named the same as any one of the variables 
#+ used in the function, it will not be able to be accessed.  To fix
#+ this, it's possible to only use positional parameters and not
#+ give them any names, but this would make the code more difficult
#+ to read and modify.  

## SIZE_OF_OFFSET
# the offset is to make room for the first two values
#+ of the array, where the shape is:
#` [SHAPE_LENGTH, DEFAULT_VALUE, SHAPE..., VALUES]
OFFSET_SIZE=2
OFFSET_SHAPE_LENGTH=0
OFFSET_DEFAULT_VALUE=1

## create-array
# creater-array {shape =~ /[0-9]+(,[0-9]+)*/} default
# creates an array of this shape, to be used like:
#+ array=( $(create-array 2,3 default) )
#+ for a 2 row by 3 column array initialized to "default"
function create-array() {
    local shape IFS dimension dims default tmp
    shape=$1; shift
    default=$@
    IFS=,
    tmp=( $shape )
    dims=( "$default" $shape )
    echo ${#tmp[@]} ${dims[@]}
}

## get-real-index
# get-real-index array index
# returns the real index of the array for the given index
#+ if the shape is {2,3} then an index of {1,0} is equal to
#` OFFSET + 1 + 1*3+0
#+ likewise, if the shape is {4,5,6} and the index is {1,2,3}
#` OFFSET + 1 + 1*(5*6*1) + 2*(6*1) + 3*(1)
#+ We could also define it as such: let I be the vector of indices,
#+ and S be the shape of the array, then V is:
#` [product([S_j for i<j<|S|] for 1<=i<|S|] where product([]) = 1
#+ Then ret = I dot S.  Therefore:
#` ret = OFFSET+I[n]*(1*S[n+1]*...*S_m) for 1<=n<offset
function get-real-index() {
    local array index offset tmp i ret indarray IFS
    array=$1
    index=$2
    tmp=$array[$OFFSET_SHAPE_LENGTH]
    offset=${!tmp}
    declare -i ret
    declare -i product
    ret=$offset+$OFFSET_SIZE
    IFS=, indarray=( $index )
    for((i=0;i<offset;i++)); do
	product=${indarray[$i]}
	for((j=i+1;j<offset;j++)); do
	    tmp=$array[$j+$OFFSET_SIZE]
	    product="$product*${!tmp}"
	done
	ret+=$product
    done
    echo $ret
}

## index
# index {arg =~ /[a-zA-Z_]+\[[0-9]+(,[0-9]+)*\]=?} {value =~ /(.*)?/}
# indexes the array and calls the appropriate helper function if necessary
#+ for example:
#` index array[1,2]
#+ retrieves the second row, third column of array
#` index array[1,0]= 2
#+ sets the second row, first column of array to 2
function index() {
    local arg array index
    arg=$1; shift
    array=${arg%%\[*}   # array = $arg =~ /^(.*?)\[/
    arg=${arg#$array\[}
    index=${arg%%\]*}   # index = $arg =~ /\[(.*?)\]/
    arg=${arg#$index\]}
    case $arg in
	*\=) index-set $array $index "$@";;
	*) index-get $array $index "$@";;
    esac
}

## index-set
# index-set array index value
# sets the value of arg (described earlier) to value
function index-set() {
    local value array index
    array=$1; shift
    index=$1; shift
    value=$@
    # eval... I'm sorry :(
    eval "$array[$(get-real-index $array $index)]=\$value"
}

## index-get
# index-get array index
# gets the value of the array at that index if it exists,
#+ else it returns the default value
function index-get() {
    local array index tmp
    array=$1
    index=$2
    tmp=$array[$(get-real-index $array $index)]
    if [[ -z ${!tmp+isset} ]]; then
	# it wasn't set, so pass the default instead
	tmp=$array[$OFFSET_DEFAULT_VALUE]
    fi
    echo ${!tmp}
}

A=( $(create-array 2,2,2 0) )
get-real-index A $1  # => 7
get-real-index A $2  # => 12
index A[$1]= hello
index A[$2]= world
index A[1,0,0]= more than one word
echo ${A[@]}         # => 3 0 2 2 2 hello more than one word world
for((i=0;i<2;i++)); do                                 # => 0,0
    for((j=0;j<2;j++)); do                             # => hello,0
	for((k=0;k<2;k++)); do                         # => ---
	    [[ $k != 0 ]] && echo -n ,                 # => more than one word,0
	    echo -n "$(index A[$i,$j,$k])"             # => 0,world
	done                                           # => ---
	echo
    done
    echo ---
done
