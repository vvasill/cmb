#!/bin/bash

FREQ=$1
FWHM=$2

for fr in $FREQ
do	
	outfile='./res/extract_'$fr
	> $outfile
	./join_all.sh './in_data/calib_'$fr'_60' './in_data/calib_'$fr'_35' './in_data/calib_'$fr'_5' './in_data/calib_'$fr'_0' > $outfile

	#sort -n list > sorted_list

	#awk 'FNR==NR{a[$1]=$2;next} ($1 in a) {print a[$1], $0}' restricted_list sorted_list > $outfile
done

#./join_all.sh './res/extract_030' './res/extract_044' './res/extract_070' './res/extract_100' './res/extract_143' './res/extract_217' > './res/extract'


