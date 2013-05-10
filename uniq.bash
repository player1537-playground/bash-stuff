#!/bin/bash

. ./hash.bash

new_hash words
while read -r line; do
    words {$line,} &>/dev/null || echo $line
    words {$line,}=
done

