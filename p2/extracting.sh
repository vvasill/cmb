#!/bin/bash

FREQ=$1
FWHM=$2
mode=$3
sigma=$4
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

			if [ "$mode" == "S" ]
			then
				sex_config='../sex_config/config_S'
				outfile='./source_lists/'$sigma'/S_big_area_sources_'$i'_'$fr'_'$fw
			fi
			if [ "$mode" == "T" ]
			then
				sex_config='../sex_config/config_T'
				outfile='./source_lists/'$sigma'/T_big_area_sources_'$i'_'$fr'_'$fw
			fi

			> $outfile
			echo $fr' '$fw' '$i
			
			#SExtractor processing
			sextractor $MAP -c $sex_config -DETECT_THRESH $sigma -ANALYSIS_THRESH $sigma > /dev/null 2>&1
			sed -i -e 's/+//g' sex_output 
			awk 'BEGIN{CONVFMT="%.9f"}{for(i=1; i<=NF; i++)if($i~/^[0-9]+([eE][+-][0-9]+)?/)$i+=0;}1' sex_output > tmp && mv tmp sex_output 

			if [ "$mode" == "T" ]
			then
				awk '{printf "%s %s %s %s %s\n", $1, $2, '0', $3, $4}' sex_output > tmp && mv tmp sex_output
			fi

			cat sex_output >> $outfile	
		done	
	done
done

#empty_trash	
if [ -f sex_output ]; then rm sex_output; fi	

