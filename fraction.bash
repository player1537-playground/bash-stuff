#!/bin/bash

_a=
_b=
_a_num=
_a_den=
_b_num=
_b_den=
declare -A _vars  # associative array
_vars=([scale]=0)
_paren_stack=()
_paren_pointer=0
_display_result=1

function __() {
    _ "$@" 2>/dev/null
}

function ___() {
    local line prog
    line=
    prog=${1:-__}
    while true; do
	echo -n '> '
	read line
	case "$line" in
	    quit) break;;
	    reset) _vars=()
		continue;;
	esac
	$prog $(expandmath $line)
    done
}

function expandmath() {
    local cur temp assignment
    cur="$@"
    if [ -n "${cur//[^=]/}" ]; then
	assignment=rawr
	temp=${cur%%=*}
	cur=${cur#*=}
    fi
    cur=${cur//\+/ \+ }
    cur=${cur//\// \/ }
    cur=${cur//\-/ \- }
    cur=${cur//\@/ \@ }
    cur=${cur//\^/ \^ }
    cur=${cur//\=/\= }
    cur=${cur//\[/\[ }
    cur=${cur//\]/ \] }
    if [ -n "$assignment" ]; then
	echo "$temp= $cur"
    else
	echo "$cur"
    fi
}

function _() {
    #local a oper b
    local varname oldoper funcall args scale
    echo "_ $@" >&2
    varname=
    oldoper=
    funcall=
    _a=$1
    if expr $_a : ".*=" &>/dev/null; then
	varname=${_a%=}
	_a=$1; shift
	if isfuncall $varname; then
	    assignfun $varname "$@"
	    return
	fi
    fi
    set -- + "$@" + 0
    _a=0
    while [ $# -gt 1 ]; do
	oper=$1; shift
	_b=$1; shift
	_a=${_a//%/\/}
	_b=${_b//%/\/}
	if isfuncall $_b; then
	    funcall=${_b%\[}
	    args=()
	fi
	if [ $_b = \[ ] || isfuncall $_b; then
	    _paren_stack[_paren_pointer++]=$_a
	    _paren_stack[_paren_pointer++]=$oper
	    _a=$1; shift
	    continue
	fi
	varlookup
	if [ $oper = \] ]; then
	    shift
	    if [ -n "$funcall" ]; then
		args+=($_a)
		CALL $funcall ${args[@]}
	    else
		oldoper=$_b
		set -- $oldoper "$@"
	    fi
	    _b=$_a
	    oper=${_paren_stack[--_paren_pointer]}
	    _a=${_paren_stack[--_paren_pointer]}
	fi
	case $oper in
	    \+) PLUS;;
	    \-) MINUS;;
	    \/) DIVIDE;;
	    \@) TIMES;;
	    \^) POWER;;
	    \,) args+=($_a)
		_a=$_b;;
	    *) echo "Unknown oper: '$_a' [$oper] '$_b'";;
	esac
    done
    simplify
    if [ -n "$varname" ]; then
	_vars[$varname]=$_a
    fi
    if [ $_display_result = 1 ]; then
	scale="${_vars[scale]}"
	fractionalize
	if [ -z "$scale" -o "$scale" = 0 ]; then
	    echo $_a
	else
	    if [ $_a_den = 1 ]; then
		echo $_a_num.0
	    else
		_a=$(decimalapprox $scale)
		while [ ${_a:0:1} = 0 ]; do
		    _a=${_a#0}
		done
		while [ ${_a: -1:1} = 0 ]; do
		    _a=${_a%0}
		done
		echo $_a
	    fi
	fi
    fi
}

function decimalapprox() {
    local scale denom ret carry temp cache
    scale=$1
    denom=$_a_den
    ret=
    carry=1
    cache=:
    
    while [ ! $((scale--)) = 0 ]; do
    #&& [ ! $carry = 00 ]; do
	cache=$cache$carry:
	temp=$(($carry / $denom))
	ret=$ret$temp
	carry=$(($carry-$temp*$denom))0
    done
    decimalmultiply $_a_num 0.${ret/?/}
}

function addalldecimal() {
    local a b
    a=$1; shift
    while [ $# -gt 0 ]; do
	b=$1; shift
	a=$(adddecimal $a $b)
    done
    echo $a
}

function adddecimal() {
    local a b temp carry ret i cura curb
    a=$1
    b=$2
    carry=0
    ret=
    if [ -z "${a//[^.]/}" ]; then
	a=$a.0
    fi
    if [ -z "${b//[^.]/}" ]; then
	b=$b.0
    fi
    
    # Make the length after the decimal place equal
    if [ $(expr length ${a#*.}) -gt $(expr length ${b#*.}) ]; then
	temp=$a
	a=$b
	b=$temp
    fi
    while [ $(expr length ${a#*.}) -lt $(expr length ${b#*.}) ]; do
	a=${a}0
    done
    
    # Make the length before the decimal place equal
    if [ $(expr length ${a%.*}) -gt $(expr length ${b%.*}) ]; then
	temp=$a
	a=$b
	b=$temp
    fi
    while [ $(expr length ${a%.*}) -lt $(expr length ${b%.*}) ]; do
	a=0${a}
    done
    
    for((i=${#a}-1;i>=0;i--)); do
	cura=${a:$i:1}
	curb=${b:$i:1}
	if [ $cura = . ]; then
	    ret=.$ret
	else
	    temp=$(($cura + $curb + $carry))
	    if [ ${#temp} = 1 ]; then
		ret=$temp$ret
		carry=0
	    else
		ret=${temp#?}$ret
		carry=1
	    fi
	fi
    done
    echo $ret
}


function decimalmultiply() {
    local a dec carry numdecplaces i cura curdec temp ret j toadd
    a=$1
    dec=$2
    carry=0
    ret=
    numdecplaces=$(expr length ${dec#*.})
    toadd=()
    dec=${dec//./}
    if [ ${#a} -lt ${#dec} ]; then
	a=$(x 0 $((${#dec}-${#a})))$a
    elif [ ${#dec} -lt ${#a} ]; then
	dec=$(dec 0 $((${#a}-#{dec})))
    fi

    for((j=${#dec}-1;j>=0;j--)); do
	curdec=${dec:$j:1}
	if [ $((${#dec}-$j-1)) = 0 ]; then
	    ret=
	else
	    ret=$(x 0 $((${#dec}-$j-1)))
	fi
	for((i=${#a}-1;i>=0;i--)); do
            cura=${a:$i:1}
            temp=$(($cura * $curdec + $carry))
            if [ ${#temp} = 1 ]; then
		temp=0$temp
            fi
            ret=${temp#?}$ret
            carry=${temp%?}
	done
	ret=$carry$ret
	if [ -n "$numdecplaces" ]; then
	    if [ $numdecplaces = ${#ret} ]; then
		ret=$numdecplaces.0
	    else
		ret=${ret:0:${#ret}-$numdecplaces}.${ret:${#ret}-$numdecplaces:$numdecplaces}
	    fi
	fi
	toadd+=($ret)
    done
    addalldecimal "${toadd[@]}"
}

# Tests if $x is a fraction
function frac() {
    local x
    x=$1
    expr $x : '.*/' &>/dev/null
}

function fractionalize() {
    if ! frac $_a; then
	_a=$_a/1
    fi
    if ! frac $_b; then
	_b=$_b/1
    fi
    _a_num=${_a%/*}
    _a_den=${_a#*/}
    _b_num=${_b%/*}
    _b_den=${_b#*/}
}

function isvar() {
    local x
    x=$1
    [ -n "${x//[ABCDEFGHIJKLMNOPQRSTUVWXYZ0-9\/.\-]/}" ]
}

function isfuncall() {
    local x
    x=$1
    expr $x : "..*\[" &>/dev/null && isfun ${x%\[} 
}

function isfun() {
    local x
    x=$1
    [ -n "{x//[abcdefghijklmnopqrstuvwxyz0-9\/\-]/}" ]
}

# Looks up $_a and $_b if they're a variable
function varlookup() {
    if isvar $_a; then
	_a=${_vars[$_a]}
    fi
    if isvar $_b; then
	_b=${_vars[$_b]}
    fi
    if [ -n "${_a//[^.]/}" ]; then
	_a_den=1$(x 0 $(expr length ${_a#*.}))
	_a_num=${_a//./}
	_a=$_a_num/$_a_den
    fi
    if [ -n "${_b//[^.]/}" ]; then
	_b_den=1$(x 0 $(expr length ${_b#*.}))
	_b_num=${_b//./}
	_b=$_b_num/$_b_den
    fi
}

function gcd() {
    local a b
    a=$1
    b=$2
    if [ $a = 0 -o $b = 0 ]; then
	echo 1
    elif [ $a = 1 -o $b = 1 ]; then
	echo 1
    elif [ $a = $b ]; then
	echo $a
    elif [ $a -gt $b ]; then
	gcd $((a-b)) $b
    else
	gcd $a $((b-a))
    fi
}

function simplify() {
    local gcd
    fractionalize
    gcd=$(gcd ${_a_num#-} ${_a_den#-})
    _a=$(($_a_num / $gcd))/$(($_a_den / $gcd))
    fractionalize
    if [ $_a_den = 1 ]; then
	_a=$_a_num
    fi
}

function samedenom() {
    ((_a_num *= _b_den))
    ((_b_num *= _a_den))
    ((_a_den *= _b_den))
    ((_b_den  = _a_den))
}

function assignfun() {
    local fullname funname argname
    fullname=$1; shift
    funname=${fullname%\[*}
    argname=${fullname#*\[}
    argname=${argname%\]}
    _vars[$funname]="$argname:$*"
}

function PLUS() {
    if frac $_a || frac $_b; then
	fractionalize
	samedenom
	_a=$(($_a_num + $_b_num))/$_b_den
    else
	_a=$(($_a + $_b))
    fi
}

function MINUS() {
    if frac $_a || frac $_b; then
	fractionalize
	samedenom
	_a=$(($_a_num - $_b_num))/$_b_den
    else
	_a=$(($_a - $_b))
    fi
}

function TIMES() {
    if frac $_a || frac $_b; then
	fractionalize
	_a=$(($_a_num * $_b_num))/$(($_a_den * $_b_den))
    else
	_a=$(($_a * $_b))
    fi
}

function DIVIDE() {
    local temp
    fractionalize
    _b=$_b_den/$_b_num
    TIMES
}

function POWER() {
    local i old_b old_a
    fractionalize
    if [ ! $_b_den = 1 ]; then
	echo "Fractional powers not supported" >&2
	exit 1
    fi
    if [ $_b_num = 0 ]; then
	_a=1
    else
	old_b=$_b_num
	_b=$_a
	for((i=1; i<$old_b; i++)); do
            TIMES
	done
    fi
}

function CALL() {
    local envbackup key funcall funval funargs curarg IFS disp
    declare -A envbackup
    for key in ${!_vars[@]}; do
	envbackup[$key]="${_vars[$key]}"
    done
    funcall=$1; shift
    funval="${_vars[$funcall]}"
    funargs=${funval%%:*}
    IFS=,
    for curarg in ${funargs}; do
	_vars[$curarg]=$1; shift
    done
    IFS=' '
    disp=$_display_result
    _display_result=0
    _ ${funval#*:}
    _display_result=$disp
    
    _vars=()
    for key in ${!envbackup[@]}; do
	_vars[$key]="${envbackup[$key]}"
    done
}

if [ "$1" = test ]; then
    _ x= 3%2 + 5 - 6 - 3 @ 4 / 3
    _ y= 3 @ x
    _ y / 2
    _ 4 + [ 3 @ x ] @ 2
    _ 1 + [ 2 + 3 ] + 4
    _ == 3 - x @ y
    _ 4 @ = 
    _ 3 + [ 4 @ [ 7 - 3 ] ] - 7
    _ 3 + [ 4 @ 4 ] - 7
    _ 3 + 16 - 7
    _ F[x,y]= 3 @ x + y
    _ G[x]= 7 @ x
    _ H[]= 3
    _ f[x]= x ^ 2
    _ 4 + [3 + x] @ 2 
    _ 3 @ x
elif [ "$1" = test2 ]; then
    _ F[x]= G[ x ] + 1
    _ G[x]= H[ x ] + 1
    _ H[x]= x + 1
    _ F[ 3 ]
elif [ "$1" = test3 ]; then
    _ 11/213
elif [ "$1" = test4 ]; then
    adddecimal 1.234 4.321
elif [ -n "$1" ]; then
    _ "$@"
fi