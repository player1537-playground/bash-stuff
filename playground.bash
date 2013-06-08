#!/bin/bash

declare -A arr
arr[A]=3
arr[A1]=5
arr[A2]=7
arr[A3]=8
arr[B1]=meow
arr[B2]=88
arr[C1]=100

for((a=1;a<=${arr[A]};a++)); do
    echo ${arr[A$a]}
done
