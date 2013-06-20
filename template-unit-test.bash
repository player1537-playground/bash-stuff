#!/bin/bash

source colorize.bash || function color() { shift; echo "$@"; }

TEMPLATE=$PWD/template.bash

function one-test() {
    local title input expected output
    title=$1
    input=$2
    expected=$3
    output=$(echo "$input" | $TEMPLATE /dev/stdin)
    if [[ $output == $expected ]]; then
	success
    else
	failure
    fi
}

function success() {
    echo "$(color Green "[+]") $title passed"
}

function failure() {
    echo "$(color Red "[-]") $title failed"
    printf "%s:\n%s\n%s\n" "Input" "$input" "===" \
	                   "Output" "$output" "---" \
	                   "Expected" "$expected" "___"
}

one-test "Basic output" "$(cat <<EOF
line 1
line 2
EOF
)" "$(cat <<EOF
line 1
line 2
EOF
)"

export TESTING=rawr 
one-test "Retrieving variables" "$(cat <<EOF
before {{ \$TESTING }} after
EOF
)" "$(cat <<EOF
before $TESTING after
EOF
)"

one-test "Setting variables and retrieving them w/spaces" "$(cat <<EOF
{= MY_VAR =}
rawr
{==}
This is {{ \$MY_VAR }}.
EOF
)" "$(cat <<EOF
This is rawr.
EOF
)"

one-test "Setting variables and retrieving them w/o spaces" "$(cat <<EOF
{= MY_VAR =}
rawr
{==}
This is {{\$MY_VAR}}.
EOF
)" "$(cat <<EOF
This is rawr.
EOF
)"

one-test "If statements w/setting variables" "$(cat <<EOF
{= BOOLEAN =}
true
{==}
{% if [[ \$BOOLEAN == true ]]; then %}
truthy
{% fi %}
EOF
)" "$(cat <<EOF
truthy
EOF
)"

one-test "Calling other programs using {% %} w/spaces" "$(cat <<EOF
Hello {% yes rawr | head -n 3 %} world
EOF
)" "$(cat <<EOF
Hello 
rawr
rawr
rawr
 world
EOF
)"

one-test "Calling other programs using {% %} w/o spaces" "$(cat <<EOF
Hello {%yes rawr | head -n 3%} world
EOF
)" "$(cat <<EOF
Hello 
rawr
rawr
rawr
 world
EOF
)"

one-test "Calling other programs using {{ \$( ) }} w/spaces" "$(cat <<EOF
Hello {{ \$(yes rawr | head -n 3 | tr "\n" " ") }} world
EOF
)" "$(cat <<EOF
Hello rawr rawr rawr  world
EOF
)"

one-test "Calling other programs using {{ \$( ) }} w/o spaces" "$(cat <<EOF
Hello {{\$(yes rawr | head -n 3 | tr "\n" " ")}} world
EOF
)" "$(cat <<EOF
Hello rawr rawr rawr  world
EOF
)"

one-test "Recalling variables with \"\" quotes" "$(cat <<EOF
{= VAR =}
this is var
{==}
VAR is "\$VAR", for realz
EOF
)" "$(cat <<EOF
VAR is "this is var", for realz
EOF
)"
