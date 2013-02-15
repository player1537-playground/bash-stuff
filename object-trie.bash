#!/bin/bash

source objects.bash
init

new_class Trie <<'EOF'
function init():

function add(string):
first=${string:0:1}
rest=${string:1}
if [ ! -f children-$first ]; then
  new=$(allocate_object Trie)
  echo $new > children-$first
else
  new=$(cat children-$first)
fi
if [ -n "$rest" ]; then
  call_method $new add $rest
else
  call_method $new end $first
fi

function end(letter):
echo $letter > endpoint

function isEnd():
[ -f endpoint ]

function exists(string=):
if [ -z "$string" ]; then
  if [ -f endpoint ]; then
    echo 1
  else
    echo 0
  fi
else
  first=${string:0:1}
  rest=${string:1}
  if [ -f children-$first ]; then
    call_method $(cat children-$first) exists $rest
  else
    echo 0
  fi
fi
EOF

function main() {
    local new=$(allocate_object Trie)
    local word
    for word in hello world blue black bake; do
	call_method $new add $word
    done
    for word in hello testing black bake bak; do
	echo "$word: $(call_method $new exists $word)"
    done
}

main "$@"