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
MAP=/home/vo/Planck/DR2/m_smica2.01.fts

delta="20.0"
FWHM="0"
LFREC="030 044 070 100 143 217"
factor=3.0
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077"

cd ./corr_maps

count=0
for fr in $LFREC
do
	BW_str=( $beamwidth )
	BW=${BW_str[$count]}
	cor_win=$( echo $BW*$factor*60.0 | bc )
	echo $cor_win
	
	for fw in $FWHM
	do
		case $fw in
		0)
			map1='M'$fr
			map2='MAP';;
		*)	
			map1_0='../p2/maps/'$fr'_'$fw'_smooth_map.fts'
			map2_0='../p2/maps/smica_'$fw'_smooth_map.fts'
			map1='map1_0'
			map2='map2_0'
		esac
		
		cat  big_areas_list_equ | grep -v '^#' |awk -v fr=$fr -v fw=$fw '{printf "map_q%s_%s_%s %sd %sd\n", $1, fr, fw, $2, $3}' > coord_list$$
		f2fig ${!map1} -fzq1 coord_list$$ -zd $delta'd' -Cs nat
		cat  big_areas_list_equ | grep -v '^#' |awk -v fr=$fr -v fw=$fw '{printf "smica_map_q%s_%s_%s %sd %sd\n", $1, fr, fw, $2, $3}' > coord_list$$
		f2fig ${!map2} -fzq1 coord_list$$ -zd $delta'd' -Cs nat

		difmap -cf -1 -o inv_map2 ${!map2}
		difmap -sum -o sum_map ${!map1} inv_map2
		difmap -cw $cor_win -o './maps/mos_corr_'$fr'_'$fw'.fts' sum_map ${!map2}

		cat  big_areas_list_equ | grep -v '^#' |awk -v fr=$fr -v fw=$fw '{printf "inv_q%s_%s_%s %sd %sd\n", $1, fr, fw, $2, $3}' > coord_list$$
		f2fig  inv_map2 -fzq1 coord_list$$ -zd $delta'd' -Cs nat
		cat  big_areas_list_equ | grep -v '^#' |awk -v fr=$fr -v fw=$fw '{printf "sum_q%s_%s_%s %sd %sd\n", $1, fr, fw, $2, $3}' > coord_list$$
		f2fig  sum_map -fzq1 coord_list$$ -zd $delta'd' -Cs nat
		cat  big_areas_list_equ | grep -v '^#' |awk -v fr=$fr -v fw=$fw '{printf "corr_q%s_%s_%s %sd %sd\n", $1, fr, fw, $2, $3}' > coord_list$$
		f2fig './maps/mos_corr_'$fr'_'$fw'.fts' -fzq1 coord_list$$ -zd $delta'd' -Cs nat
	done
done

#empty_trash	
if [ -f coord_list$$ ]; then rm coord_list$$; fi

