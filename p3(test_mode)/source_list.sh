#!/bin/bash

> source_list
awk '{print $1, $2}' Planck_list > restricted_list

FREQ="030 044 070 100 143 217"
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077"
FWHM="0 5 35 60"

for fr in $FREQ
do
	for fw in $FWHM
	do	
		infile='./out_data/extra_calib_data_'$fr'_'$fw
		awk -v fr=$fr -v fw=$fw 'BEGIN{FS="_"}{printf "%s fr_%s fw_%s\n", $1, fr, fw}' $infile > used_list
		sort -n used_list > sorted_used_list
		awk 'FNR==NR{a[$1]=$2;b[$1]=$3;next} ($1 in a) {print $1, $2, a[$1], b[$1]}' sorted_used_list restricted_list >> source_list
		#join -o 1.1 2.1 1.2 2.2 2.3 Planck_list sorted_used_list > source_list
		cat source_list | grep "fr_$fr" | grep "fw_$fw" | wc -l  
	done	
done

rm used_list
rm sorted_used_list
rm restricted_list

#cat source_list | grep "fr_030" | grep "fw_0" | awk '{printf "%s, ", $2}' | sed -e 's/\_/\\_/g' > sources
