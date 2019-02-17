#!/bin/bash

FREQ=$1
FWHM=$2
home_path=$3
sigma=1.0
delta=20.0

cd ./big_areas
check_dir='./source_lists/'
if [ ! -f $check_dir ]; then mkdir $check_dir; fi

for fr in $FREQ
do	
	for fw in $FWHM
	do
		#loop_on_big_areas
		cat ../big_areas_list_equ | grep -v '^#' | while read areas_line
		do 
			#names def
			str1=( $areas_line )
			i=${str1[0]}
			MAP=$home_path'/p2/big_areas/q'$i'_'$fr'_'$fw'_'$delta'.fts'

			sex_config='../sex_config/config'
			outfile='./source_lists/big_area_sources_'$i'_'$fr'_'$fw
			> $outfile
			echo $fr' '$fw' '$i
			
			#SExtractor processing
			sextractor $MAP -c $sex_config -DETECT_THRESH $sigma -ANALYSIS_THRESH $sigma > /dev/null 2>&1
			#let's throw away exponents:
			sed -i -e 's/+//g' sex_output 
			awk 'BEGIN{CONVFMT="%.9f"}{for(i=1; i<=NF; i++)if($i~/^[0-9]+([eE][+-][0-9]+)?/)$i+=0;}1' sex_output > tmp && mv tmp sex_output
			cat sex_output >> $outfile	

		done	
	done
done

#empty_trash	
if [ -f sex_output ]; then rm sex_output; fi	

