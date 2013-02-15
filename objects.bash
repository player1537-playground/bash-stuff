#!/bin/bash -e

# Use directories to represent objects.  methods are files of bash code (method-foo.bash)
if [ ! "${BASH_SOURCE}" = $0 ]; then
    OLD_PWD=$PWD
    cd $(dirname $BASH_SOURCE)
fi
THIS_PWD=$PWD
FULL_NAME=$THIS_PWD/$(basename $0)
if [ ! "${BASH_SOURCE}" = $0 ]; then
    FULL_NAME=$THIS_PWD/$(basename ${BASH_SOURCE})
fi
WORK=$PWD/work
ALLOCATED_OBJECTS=$WORK/objects
OBJECT_DEFINITIONS=$WORK/classes
OBJECT_PREFIX=$ALLOCATED_OBJECTS/obj-
METHOD_PREFIX=method-

function init() {
    mkdir -p $ALLOCATED_OBJECTS
    rm -rf $ALLOCATED_OBJECTS/*
    mkdir -p $OBJECT_DEFINITIONS
    rm -rf $OBJECT_DEFINITIONS/*
}

function allocate_object() {
    local class_name next_object_num next_object_name file
    class_name=$1; shift
    next_object_num=$((1 + $(ls $ALLOCATED_OBJECTS | wc -l)))
    next_object_name=$OBJECT_PREFIX$next_object_num
    mkdir $next_object_name
    for file in $OBJECT_DEFINITIONS/$class_name/*; do
	ln -s $file $next_object_name/${file##*/}
    done
    echo $next_object_num > $next_object_name/this
    if ! call_method $next_object_num init "$@"; then
	exit 1
    fi
    echo $next_object_num
}

function A() {
    allocate_object "$@"
}

function call_method() {
    local alloc_num fun_name full_fun_name old_pwd
    alloc_num=$1; shift
    if [ $alloc_num = this ]; then
	cd .
    else
	old_pwd=$PWD
	cd $THIS_PWD
	if ! cd $OBJECT_PREFIX$alloc_num; then
	    echo "cd failed, check the code" >&2
	    read
	fi
    fi
    fun_name=$1; shift
    full_fun_name=$METHOD_PREFIX$fun_name
    bash $METHOD_PREFIX$fun_name "$@"
    cd $old_pwd
}

function new_class() {
    local class_name full_name line curfun args funname IFS arg curargnum
    class_name=$1
    full_name=$OBJECT_DEFINITIONS/$class_name
    mkdir -p $full_name
    while true; do
	read line || break
	if expr "$line" : "function.*:" &>/dev/null; then
	    funname=$(expr "$line" : "function *\([^: (]*\)")
	    curfun=$full_name/$METHOD_PREFIX$funname
	    echo "source $FULL_NAME" > $curfun
	    if expr "$line" : "function.*(.*).*:" &>/dev/null; then
		args=${line#*$funname\(}
		args=${args%):}
		IFS=,
		curargnum=1
		for arg in $args; do
		    if [ -n "${arg//:/}" ]; then
			echo ${arg%=*}='${'${curargnum}':-'${arg#*=}'}' >>$curfun
		    else
			echo $arg='$'${curargnum} >>$curfun
		    fi
		    ((curargnum++))
		done
	    fi
	else
	    echo "$line" >> $curfun
	fi
    done
}

function sub_class() {
    local super_class full_name full_super_class
    super_class=$1
    this_class=$2
    full_name=$OBJECT_DEFINITIONS/$this_class
    full_super_class=$OBJECT_DEFINITIONS/$super_class
    mkdir -p $full_name
    cp $full_super_class/* $full_name/ -r
    echo $super_class > $full_name/super
    cat | new_class $this_class
}

function super() {
    bash $OBJECT_DEFINITIONS/$(cat super)/$0 "$@"
}

if [ "${BASH_SOURCE}" = $0 ]; then
    function main() {
	init
	local obj
	new_class Baz <<'EOF'
function init(name):
call_method this setname $name

function setname(name):
echo $name > name

function fun:
echo "Hello $(cat name)!"

function foo:
call_method this fun
call_method this setname "Scary $(cat name)"
call_method this fun
EOF
obj=$(allocate_object Baz $1)
call_method $obj foo
new_class BazOwner <<'EOF'
function init(baz):
echo $baz > baz

function runbaz:
call_method $(cat baz) foo
EOF
local obj2=$(allocate_object BazOwner $obj)
call_method $obj2 runbaz
new_class Fibonacci <<'EOF'
function init:
function calcfib(n,a=1,b=1):
if [ $n = 0 ]; then
  echo $a
else
  echo $a
  call_method this calcfib $(($n-1)) $b $(($a+$b))
fi
EOF
local fib=$(allocate_object Fibonacci)
call_method $fib calcfib 5 
new_class LinkedList <<'EOF'
function init(data,next=null):
echo $data > data
echo $next > next

function getnext:
cat next

function isempty:
[ "$(cat next)" = null ]

function append(data):
node=$(cat this)
while ! call_method $node isempty; do
  node=$(call_method $node getnext)
done
newnode=$(allocate_object LinkedList $data null)
echo $newnode > next
function printself:
cat data
function printlist:
echo List:
node=$(cat this)
while ! call_method $node isempty; do
  call_method $node printself
  node=$(call_method $node getnext)
done
call_method $node printself
EOF
  local list=$(allocate_object LinkedList 1)
  call_method $list append 3
  call_method $list printlist
  new_class Functions <<'EOF'
function init(a):
echo $a > offset

function foo(a,b):
echo $a + $b = $(($a + $b))
cat offset
EOF
  sub_class Functions FunSub <<'EOF'
function foo(a,b):
super $b $a
EOF
  local function=$(allocate_object FunSub abc)
  call_method $function foo 5 20
    }

    main "$@"
else
    cd $OLD_PWD
fi
