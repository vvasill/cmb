#!/bin/bash

M030=/home/vo/Planck/DR2/m_030_R2.01.fts
M044=/home/vo/Planck/DR2/m_044_R2.01.fts
M070=/home/vo/Planck/DR2/m_070_R2.01.fts
M100=/home/vo/Planck/DR2/m_100_R2.02.fts
M143=/home/vo/Planck/DR2/m_143_R2.02.fts
M217=/home/vo/Planck/DR2/m_217_R2.02.fts
M353=/home/vo/Planck/DR2/m_353_R2.02.fts
M545=/home/vo/Planck/DR2/m_545_R2.02.fts
M857=/home/vo/Planck/DR2/m_857_R2.02.fts

LFREC=$1
FWHM=$2
home_path=$3
delta=20.0

if [ ! -f ./big_areas ]; then mkdir ./big_areas; fi
cd ./big_areas

for fr in $LFREC
do
	for fw in $FWHM
	do
		echo $fr' '$fw	
		
		case $fw in
		0)
			MAP='M'$fr;;
		*)
			MAP_0=$home_path'/maps/smoothed_maps/'$fr'_'$fw'_smooth_map.fts'
			MAP='MAP_0';;
		esac

		cat ../big_areas_list_equ | grep -v '^#' | awk -v fr=$fr -v fw=$fw -v d=$delta '{printf "q%s_%s_%s_%s %sd %sd\n", $1, fr, fw, d, $2, $3}' > coord_list$$		
		mapcut ${!MAP} -fzq1 coord_list$$ -zd $delta'd'
		f2fig ${!MAP} -fzq1 coord_list$$ -zd $delta'd' -Cs nat
	done
done

#empty_trash
if [ -f coord_list$$ ]; then rm coord_list$$; fi

