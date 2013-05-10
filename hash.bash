#!/bin/bash

HASH_DIR=$(mktemp -d)
trap "rm $HASH_DIR -r 2>/dev/null" EXIT

function hash() {
    case "$1" in
        new)
            > $HASH_DIR/$2
            ;;
        get)
            sed $HASH_DIR/$2 -ne "s~^$3\~\(.*\)$~\1~p"
            ;;
        set)
            if egrep "^$3~" $HASH_DIR/$2 &>/dev/null; then
                sed $HASH_DIR/$2 -i -e "s~^\($3\~\).*$~\1$4~"
            else
                echo "$3~$4" >> $HASH_DIR/$2
            fi
            ;;
        *)
            echo "Unrecognized message: $1"
            ;;
    esac
}

#hash new rawr
#hash set rawr x meow
#hash set rawr abc testing
#echo x is $(hash get rawr x)
#echo
#cat $HASH_DIR/rawr

function new_hash() {
    local name=$1
    local sep='='
    >$HASH_DIR/$name
    eval "
function $name() {
    case \$1 in
        *=*)
            local tmp=\${1%=}
	    if egrep \"^\$tmp${sep}\" $HASH_DIR/$name &>/dev/null; then
		sed $HASH_DIR/$name -i -e \"s~^\(\$tmp${sep}\).*$~\1\$2~\"
	    else
		echo \"\$tmp${sep}\$2\" >> $HASH_DIR/$name
	    fi
	    ;;
	*)
	    grep -qs \"\$1${sep}\" $HASH_DIR/$name && sed $HASH_DIR/$name -ne \"s~^\$1${sep}\(.*\)$~\1~p\"
	    ;;
    esac
}
"
}

#new_hash meow
#meow x= rawr
#meow rawr= d
#echo x is $(meow x)
#meow x= chicken
#echo x is now $(meow x)
#cat $HASH_DIR/meow
