#!/bin/bash

## $BASH_SEP
# This is the internal separator for Bash's 
#+ associative arrays
BASH_SEP=__
## $TABLE_SEP
# This is the separator stored in the config
#+ file
TABLE_SEP="="
## $SECTION_PRE
# This is the prefix to define a new section
SECTION_PRE=[
SECTION_PRE_CASE=\\$SECTION_PRE
## $SECTION_SUF
# This is the suffix to define a new section
SECTION_SUF=]
SECTION_SUF_CASE=\\$SECTION_SUF

## load-config
# load-config tablename file
# $tablename is an associative array (declare -A)
#+ passed by scope.  As $file is read, it gets
#+ stored in this array.  For example:
#` declare -A MyConfig
#` load-config MyConfig MyConfigFile
function load-config() {
    local tablename file line tmp section_name var value
    tablename=$1
    file=${2:?File must not be null}
    while true; do
	read line || break
	case $line in
	    $SECTION_PRE_CASE*$SECTION_SUF_CASE) 
		section_name=${line#$SECTION_PRE}
		section_name=${section_name%$SECTION_SUF}
		;;
	    *$TABLE_SEP*) 
		var=${line%%$TABLE_SEP*}
		value=${line#*$TABLE_SEP}
		set-config-option $tablename "$section_name" "$var" "$value"
		;;
	    *)
		echo unrecognized line, "$line" >&2
		;;
	esac
    done < $file
}

## get-config-option
# get-config-option section key default
# Queries the config array for $key under
#+ $section, if it finds it, the function
#+ prints it out, otherwise, it prints
#+ $default.  For example, 
#` stamina=$(get-config-option MyConfig "Player Health" stamina 0)
function get-config-option() {
    local tablename section key default tmp
    tablename=$1
    section=$2
    key=$3
    default=$4
    tmp=$tablename[$section$BASH_SEP$key]+$default
    echo ${!tmp}
}

## set-config-option
# set-config-option tablename section key {value = $@}
# Stores the $value to $key under $section in $tablename.
#+ For example,
#` set-config-option MyConfig General "player name" John Smith
function set-config-option() {
    local tablename section key value
    tablename=$1; shift
    section=$1; shift
    key=$1; shift
    value="$@"
    eval $tablename[\$section\$BASH_SEP\$key]=\$value
}

## write-config
# write-config tablename
# Outputs to stdout the updated file form of the config
#+ file.  To send it to another file, use redirection.
#+ For example,
#` write-config MyConfig > MyConfig.config
function write-config() {
    local tablename key_array tmp tables table key
    tablename=$1
    tmp=$tablename[@]
    key_array=( $(eval echo \"\${!$tablename[@]}\") )
    declare -A tables
    for table in "${key_array[@]}"; do
	tables[${table%$BASH_SEP*}]=1
    done
    for table in "${!tables[@]}"; do
	echo $SECTION_PRE$table$SECTION_SUF
	for key in "${key_array[@]}"; do
	    if [[ ${key%$BASH_SEP*} == $table ]]; then
		tmp=$tablename[$key]
		echo ${key#*$BASH_SEP}$TABLE_SEP${!tmp}
	    fi
	done
    done
}

