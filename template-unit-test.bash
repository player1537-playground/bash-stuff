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
    printf "%s\n===\n%s\n___\n" "$output" "$expected"
}

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
