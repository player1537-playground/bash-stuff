#!/bin/bash

FILE=$1

cat - <(sed $FILE -e '1d') <<EOF | cpp | cat
#define NEW_CLASS(name) new_class name <<'END_OF_CLASS'
#define SUB_CLASS(old, new) sub_class old new <<'END_OF_CLASS'
#define EMPTY() 
#define END_CLASS() EMPTY() \
END_OF_CLASS
EOF
