#!/bin/bash

FREQ=$1
FWHM=$2
home_path=$3
mode=$4

cd ./in_data

for fr in $FREQ
do
	for fw in $FWHM
	do	
		awk 'BEGIN{FS="_"}{printf "%s %s\n", $1, $4}' 'calib_data_'$fr'_'$fw > tmp
		awk '{printf "%s %s %s %s %s\n", $1, $3, $4, $5, $6}' tmp > 'calib_'$fr'_'$fw
	done
done
