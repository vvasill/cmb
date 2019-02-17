#!/bin/bash

cd ./big_areas
if [ ! -f ./source_lists ]; then mkdir ./source_lists; fi

FREQ=$1
FWHM=$2
sigma=$3
delta=20.0

cd ./big_areas
check_dir='./source_lists/'$sigma
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
			MAP='q'$i'_'$fr'_'$fw'_'$delta'.fts'
			outfile='./source_lists/'$sigma'/T_big_area_sources_'$i'_'$fr'_'$fw
			> $outfile

			echo $fr' '$fw' '$i

			#SExtractor processing
			sextractor $MAP -c ../sex_config/config_T -DETECT_THRESH $sigma -ANALYSIS_THRESH $sigma
			sed -i -e 's/+//g' sex_output 
			awk 'BEGIN{CONVFMT="%.9f"}{for(i=1; i<=NF; i++)if($i~/^[0-9]+([eE][+-][0-9]+)?/)$i+=0;}1' sex_output > tmp && mv tmp sex_output 
			awk '{printf "%s %s %s %s %s\n", $1, $2, '0', $3, $4}' sex_output > tmp && mv tmp sex_output
			cat sex_output >> $outfile	

		done
	done
done

#empty_trash
if [ -f sex_output ]; then rm sex_output; fi	
