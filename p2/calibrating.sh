#!/bin/bash

FREQ=$1
FWHM=$2
home_path=$3
mode=$4

cd ./match

for fr in $FREQ
do	
	for fw in $FWHM
	do
		> 'calib_outfile_'$fr'_'$fw
		
		#params for flux calibration
		calib_res=( $( cat $home_path'/calib_res' | grep 'fr_'$fr | grep 'fw_'$fw ) )
		a=${calib_res[2]}
		b=${calib_res[3]}
		a_err=${calib_res[4]}
		b_err=${calib_res[5]}	
		
		cat ../big_areas_list_equ | grep -v '^#' | while read areas_line
		do 
			#names def
			str1=( $areas_line )
			i=${str1[0]}
			infile='outfile_'$i'_'$fr'_'$fw
			echo $fw' '$i' '$fr
				
			if [ "$mode" == "with" ]
			then
				#flux calibration
				awk -v a=$a -v b=$b -v num=$i -v a_err=$a_err -v a_err=$a_err '{printf "%s_%s %s %s %s %s\n", num, $1, (a*$2+b), sqrt(($2*a_err)*($2*a_err) + (a*$3)*(a*$3) + b_err*b_err), $4, $5}' $infile >> 'calib_outfile_'$fr'_'$fw
			else
				awk -v num=$i '{printf "%s_%s %s %s %s %s\n", num, $1, $2, $3, $4, $5}' $infile >> 'calib_outfile_'$fr'_'$fw
			fi
		done
	done
done

