#!/bin/bash

FREQ=$1
FWHM=$2
beamwidth=$3
home_path=$4

factor=1.5
BW_str=( $beamwidth )

M030=$home_path'/maps/m_030_R2.01.fts'
M044=$home_path'/maps/m_044_R2.01.fts'
M070=$home_path'/maps/m_070_R2.01.fts'
M100=$home_path'/maps/m_100_R2.02.fts'
M143=$home_path'/maps/m_143_R2.02.fts'
M217=$home_path'/maps/m_217_R2.02.fts'
M353=$home_path'/maps/m_353_R2.02.fts'
M545=$home_path'/maps/m_545_R2.02.fts'
M857=$home_path'/maps/m_857_R2.02.fts'

cd ./small_areas
coord_list=../temp/coord_list$$

#loop_on_freq
count=0
for fr in $FREQ
do
	#loop_on_smoothing_angles
	for fw in $FWHM
	do
		#set a size of small area for current fw/freq and map/smoothed map
		BW=${BW_str[$count]}
		fw_d=$( echo $fw/60.0 | bc -l )
		if (( $( echo $BW '>' $fw_d | bc -l ) ))
		then
			delta_small=$( echo $factor*$BW | bc -l )
		else
			delta_small=$( echo $factor*$fw_d | bc -l )	
		fi
		echo $delta_small

		#set path to current map
		case $fw in
		0)
			#MAP='M'$fr;;
			MAP_0=$home_path'/maps/m_smica2.01.fts'
			MAP='MAP_0';;
		*)
			#MAP_0=$home_path'/maps/smoothed_maps/'$fr'_'$fw'_smooth_map.fts'
			MAP_0=$home_path'/maps/smoothed_maps/smica_'$fw'_smooth_map.fts'
			MAP='MAP_0';;
		esac

		#loop_on_big_areas
		cat ../big_areas_list_equ | grep -v '^#' | while read line
		do 
			#names def
			ba_str=( $line )
			i=${ba_str[0]}
			echo "freq: $fr big area: $i FWHM: $fw"

			#coord_list: name, ra, $5
			cat '../def_coords/source_lists/big_area_sources_'$i'_'$fw | awk -v num=$i -v fr=$fr -v fw=$fw 'function abs(v) {return v < 0 ? -v : v}{ra=$4/15.0; printf "%s_%s_%s_%s %s:%s:%s %s:%s:%s\n", $1, num, fr, fw, int(ra), abs(int((ra - int(ra))*60)), abs(((ra - int(ra))*60 - int((ra - int(ra))*60))*60), int($5), abs(int(($5 - int($5))*60)), abs((($5 - int($5))*60 - int(($5 - int($5))*60))*60)}' > $coord_list

			f2fig  ${!MAP} -fzq1 $coord_list -zd $small_delta'd' -Cs nat > /dev/null 2>&1
			mapcut ${!MAP} -fzq1 $coord_list -zd $small_delta'd' > /dev/null 2>&1
		done
	done
	(( count++ ))
done
