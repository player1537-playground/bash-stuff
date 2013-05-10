#!/bin/bash

a[0]"fly:but I dunno why she swallowed a fly, perhaps she'll die."
a[1]="spider:That wiggled and jiggled and tickled inside her"
a[2]="bird:Quite absurd"
a[3]="cat:Fancy that"
a[4]="dog:What a hog"
a[5]="pig:Her mouth was so big"
a[6]="goat:She just opened her throat"
a[7]="cow:I don't know how"
a[8]="donkey:It was rather wonky"

for((i=0;i<8;i++)); do
    for((j=0;j<i;j++)); do
	animal=$(echo ${a[j]} | sed -e 's/^\([^:]*\).*$/\1/')
	response=$(echo ${a[j]} | sed -e 's/^[^:]*:\(.*\)$/\1/')
	if [ j -gt 2 ]; then
	    response="$response she swallowed a $animal, "
	    echo "There was an old lady who swallowed a "$animal,
	    echo $response
	else
	    