#!/bin/bash

join_all() {
    local file=$1
    shift

    awk '{print $1, $2, $3}' "$file" | {
        if (($# > 0)); then
            join2 - <(join_all "$@") $(($# + 1))
        else
            cat
        fi
    }
}

join2() {
    local file1=$1
    local file2=$2
    local count=$3

    local fields=$(eval echo 2.{2..$count})
    #join -a1 -a2 -e 'NA' -o "0 1.2 $fields" "$file1" "$file2"
	awk 'FNR==NR{a[$1]=$2;b[$1]=$3;next} ($1 in a) {print $0,a[$1],b[$1]}' $file1 $file2
}

join_all "$@"
