#!/bin/bash

source colorize.bash

WORK=$PWD/work
DB_ROOT=$WORK
DB=$DB_ROOT/database
LC_COLLATE=C  # needed for case-sensitivity

# exists key in array
function exists() {
    local _array _ind
    _ind=$1
    _array=$3
    _array="${_array}[$_ind]+isset"
    [[ ${!_array} ]]
}

function init() {
    rm -rf $DB
    mkdir -p $DB
}

function to-identifier() {
    local arg
    arg=$1
    arg=$(to-var $arg)
    arg=${arg//[A-Z]/}
    echo $arg
}

function is-identifier() {
    local arg res
    arg=$1
    res=$(to-identifier "$arg")
    [[ $arg == $res ]]
}

function to-var() {
    local arg
    arg=$1
    arg=${arg//[^a-zA-Z_0-9]/}
    echo $arg
}

function is-var() {
    local arg res
    arg=$1
    res=$(to-var $arg)
    [[ $arg == $res ]] && ! is-identifier $arg
}

function newrule() {
    local name
    name=$(to-identifier "$1")
    # eval... I'm sorry :(
    eval '
    function '"$name"'() {
	rule '"$name"' "$@"
    }
'
    mkdir -p $DB/$name
}

function rule() {
    local name arg IFS
    name=$1; shift
    for arg; do
	if ! is-identifier "$arg"; then
	    echo Not an identifier, "'$arg'"
	    return 1
	fi
    done
    IFS=,
    touch $DB/$name/"$*"
}

function query() {
    local outarray name args indmap arg currentind star
    if [[ $1 =~ ^_ ]]; then
	outarray=${1#_}; shift
    else
	outarray=
    fi
    name=$1; shift
    args=( "$@" )
    declare -A indmap
    declare -i currentind
    star=\*
    for arg in "${args[@]}"; do
	if is-var $arg; then
	    indmap[x$currentind]=$arg
	    args[$currentind]=$star
	fi
	currentind+=1
    done
    query-findmatches
}

# name, args, and indmap are passed by scope
function query-findmatches() {
    local IFS match pattern curind var
    IFS=,
    cd $DB/$name
    pattern="${args[*]}"
    IFS=$' \n\t'
    for match in $pattern; do
	echo -n [
	query-match-set-variables
	echo ]
    done
}

# match, indmap, and curind are passed by scope
function query-match-set-variables() {
    local matcharray IFS cur tmp var_set var verytemp len
    IFS=,
    matcharray=( $match )
    IFS=$' \n\t'
    declare -i curind
    var_set=
    for cur in "${matcharray[@]}"; do
	if [[ ${indmap[x$curind]+isset} ]]; then
	    var=${indmap[x$curind]}
	    if [[ -n $outarray ]]; then
		var_set+=${var_set:+,}$var:$cur
	    else
		color \( $var = $cur \)
	    fi
	fi
	curind+=1
    done
    echo {$var_set}
    if [[ -n $outarray ]]; then
	IFS=,
	tmp=$outarray[len]
	len=${!tmp:-0}
	for cur in $var_set; do
	    # X:value,Y:value -> ( [X]=value [Y]=value )
	    IFS=:
	    tmp=( $cur )
	    eval "$outarray[\"${tmp[0]}$len\"]=\${tmp[1]}"
	done
	eval $outarray[len]=$(($len + 1))
    fi
}

function complex-query() {
    local query fullquery queries IFS var vars result1 result2 cur_result
    fullquery="$@"
    #queries=( $query )
    vars=()
    IFS=$' \n\t'
    for var in $fullquery; do
	var=${var//,/}
	if is-var $var; then
	   vars+=( $var )
	fi
    done
    IFS=,
    declare -i iteration
    iteration=0
    declare -A result1
    declare -A result2
    for query in $fullquery; do
	if [[ $iteration == 0 ]]; then
	    cur_result=result1
	elif [[ $iteration == 1 ]]; then
	    cur_result=result2
	else
	    # join $result1 and $result2 -> $result1
	    complex-query-join
	    cur_result=result2
	fi
	IFS=$' \n\t'
#	echo $query
#	echo query _$cur_result $query
	query _$cur_result $query
	iteration+=1
    done
    if [[ $iteration -gt 0 ]]; then
	complex-query-join
    fi
    color $(declare -p result1)
}

# result1, result2, vars passed by scope
function complex-query-join() {
    local len1 len2 i j var full_results inds at_least_one_match
    len1=${result1[len]}
    len2=${result2[len]}
    declare -a full_results
    : $(declare -p result1 result2)
    for((i=0; i<$len1; i++)); do
	for((j=0; j<$len2; j++)); do
	    at_least_one_match=false
	    for var in "${vars[@]}"; do
		if exists $var$i in result1 && exists $var$j in result2; then
		    if [[ ${result1[$var$i]} != ${result2[$var$j]} ]]; then
			break
		    fi
		    at_least_one_match=true
		fi
	    done
	    if [[ $at_least_one_match == true ]]; then
		: $i,$j
		full_results+=( $i,$j )
	    fi
	done
    done
    complex-query-join-congregate
}

function complex-query-join-congregate() {
    local final_result len_final inds var tmp
    declare -A final_result
    declare -i len_final
    len_final=0
    for inds in "${full_results[@]}"; do
	IFS=,
	inds=( $inds )
	: ${inds[@]}
	for var in "${vars[@]}"; do
	    if exists $var${inds[0]} in result1; then
		final_result[$var$len_final]=${result1[$var${inds[0]}]}
	    fi
	    if exists $var${inds[1]} in result2; then
		final_result[$var$len_final]=${result2[$var${inds[1]}]}
	    fi
	done
	len_final+=1
    done
    complex-query-final-to-result1
}

function complex-query-final-to-result1() {
    local key
    for key in "${!result1[@]}"; do
	unset result1[$key]
    done
    for key in "${!final_result[@]}"; do
	result1[$key]=${final_result[$key]}
    done
    for key in "${!result2[@]}"; do
	unset result2[$key]
    done
}

function main {
    newrule blue
    blue car
    blue jeans
    blue house
    newrule red
    red apple
    red car
    red dress
    newrule nextto
    nextto cat person
    nextto person chair
    nextto mouse keyboard

    echo red X :: $(query red X)
    echo nextto cat X :: $(query nextto cat X)
    echo nextto X Y :: $(query nextto X Y)
    
    echo red X , blue X :: $(complex-query red X , blue X)
    
    echo nextto A B , nextto B C :: $(complex-query nextto A B, nextto B C)
}

init "$@"
#main "$@"
#ls -R $DB
