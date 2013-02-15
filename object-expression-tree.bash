#!/bin/bash

source objects.bash
init

new_class Value <<'EOF'
function init():

function getValue():
EOF

sub_class Value Number <<'EOF'
function init(n):
echo $n > value

function getValue():
cat value

function printSelf():
cat value
EOF

sub_class Value BinOp <<'EOF'
function init(Value1,Value2):
echo $Value1 > Value1
echo $Value2 > Value2

function getValue():
call_method this evaluateChildren

function evaluateChildren():
call_method $(cat Value1) getValue > a
call_method $(cat Value2) getValue > b

function printSelf(Op=OPER):
echo "($(call_method $(cat Value1) printSelf)$Op$(call_method $(cat Value2) printSelf))"
EOF

sub_class BinOp AddOp <<'EOF'
function getValue():
super
echo $(($(cat a) + $(cat b)))

function printSelf():
super +
EOF

sub_class BinOp SubOp <<'EOF'
function getValue():
super
echo $(($(cat a) - $(cat b)))

function printSelf():
super -
EOF

function main() {
    local tree=$(A AddOp $(A SubOp $(A Number 3) $(A Number 8)) $(A Number 2))
    local tree2=$(A AddOp $tree $(A SubOp $(A Number 7) $tree))
    echo Everything allocated
    call_method $tree2 printSelf
    call_method $tree2 getValue
}

main "$@"