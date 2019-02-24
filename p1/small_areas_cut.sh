#!/bin/bash

FREQ=$1
FWHM=$2
beamwidth=$3
home_path=$4

delta=20.0
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

if [ ! -d ./small_areas ]; then mkdir ./small_areas; fi
if [ ! -d ./temp ]; then mkdir ./temp; fi
coord_list=../temp/coord_list$$
coord_line=../temp/coord_line$$

cd ./small_areas
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

		#set path to current map
		case $fw in
		0)
			MAP='M'$fr;;
		*)
			MAP_0=$home_path'/maps/smoothed_maps/'$fr'_'$fw'_smooth_map.fts'
			MAP='MAP_0';;
		esac

		#loop_on_big_areas
		cat ../big_areas_list_equ | grep -v '^#' | while read line
		do 
			#names def
			ba_str=( $line )
			i=${ba_str[0]}
			area_num='area_'$i'.0'
			echo "freq: $fr big area: $i FWHM: $fw"

			#coord_list: name, ra, dec
			cat ../Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s %s %s\n", $1, num, fr, fw, $3, $4}' > $coord_list

			cat $coord_list | while read line
			do
				echo $line > $coord_line
				f2fig  ${!MAP} -fzq1 $coord_line -zd $small_delta'd' -Cs nat > /dev/null 2>&1
				mapcut ${!MAP} -fzq1 $coord_line -zd $small_delta'd' > /dev/null 2>&1
			done
		done
	done
done

#empty_trash
if [ -d ./temp ]; then rm -r ./temp; fi
