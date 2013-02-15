#!/bin/bash

# Inputs
#   A: Number
#   B: Number
function ADD() {
    [ -z "$A" ] && echo "No A" && return
    [ -z "$B" ] && echo "No B" && return
    echo $(($A + $B))
}

# Inputs: None
function main() {
    local A B
    A=5 B=1 ADD
    A=3
    B=2 ADD
    B=4
    A=$B B=$B ADD
    export A=4
    B=3 ADD
}

main

# Inputs
#  _A : Number
#  _B : Number
# Outputs: _A ^ _B
 
function power() {
  echo $_A ^ $_B 1>&2
  echo $(($_A ** $_B))
}
 
# Inputs
#  _A : Number
# Outputs: _A ^ 2
function square() {
  _B=2 power
}
 
function cube() {
  _B=3 power
}
 
function main() {
  _A=5 _B=4 power  # 5^4
  _A=2 _B=8 power  # 2^8
  _A=6             # <<<<<<<<<
  _B=3 power       # 6^3   | |
  _A=5 square      # 5^2   | |
  square           # 6^2 >>^ |
  _B=5             # <<<<<<<<<        
  _A=2 power       # 2^5     |
  power            # 5^6 >>>>^
}
 
main
