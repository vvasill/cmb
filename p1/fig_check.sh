#!/bin/bash

### visual checking if source is good for calibration ###

infile=$1
outfile=$2
mode=$3

skipped=./out_data/skipped_names_checking
coord_line=./temp/coord_line
>skipped

cat $infile | while read line
do
	echo $line > $coord_line
	fc_str=( $line )
	source_name=${fc_str[0]}
		
	if [ "$mode" == "control" ]; then
		echo 'source: '$source_name
		eog './figs/'$source_name'.gif' & fig_pid=$!
		echo "Is it a good source?"
		read flag </dev/tty
		if [ -n "$fig_pid" -a -e /proc/$fig_pid ]; then
			kill $fig_pid
		fi
	fi
	if [ "$mode" == "auto" ]; then
		flag='y'
	fi
			
	awk -v flag=$flag '{printf "%s %s %s %s %s flag_%s\n", $1, $2, $3, $4, $5, flag}' $coord_line >> $outfile
	if [ "$flag" == "n" ]; then echo $source_name >> $skipped; fi	
done
