#!/bin/bash

FWHM=$1
home_path=$2
sigma=$3

delta=20.0

cd ./def_coords
if [ ! -d ./source_lists ]; then mkdir ./source_lists; fi
coord_list=../temp/coord_list$$

for fw in $FWHM
do
	case $fw in
		0)
			MAP=$home_path'/maps/m_smica2.01.fts';;
		*)
			MAP=$home_path'/maps/smoothed_maps/smica_'$fw'_smooth_map.fts';;
	esac

	cat ../big_areas_list_equ | grep -v '^#' |awk -v fw=$fw '{printf "q%s_%s %sd %sd\n", $1, fw, $2, $3}' > $coord_list
	mapcut $MAP -fzq1 $coord_list -zd $delta'd'
	f2fig  $MAP -fzq1 $coord_list -zd $delta'd' -Cs nat -gr g -d1 0.7 -d2 0.7

	#loop_on_big_areas
	cat ../big_areas_list_equ | grep -v '^#' | while read areas_line
	do 
		str1=( $areas_line )
		i=${str1[0]}
		outfile='./source_lists/big_area_sources_'$i'_'$fw
		big_area_map='q'$i'_'$fw'.fts'	

		echo $i $fw	
	
		#SExtractor processing
		sextractor $big_area_map -c ../sxt_config/config -DETECT_THRESH $sigma -ANALYSIS_THRESH $sigma 
		sed -i -e 's/+//g' sxt_output
		sed -i -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' sxt_output 
		cat sxt_output > $outfile
	done
done

#empty_trash
if [ -f sxt_output ]; then rm sxt_output; fi
