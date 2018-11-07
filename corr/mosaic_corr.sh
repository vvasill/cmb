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
FWHM="5"
FREQ="030 044 070 100 143 217"
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077"
factor=3.0

BW_str=( $beamwidth )
count=0
for fr in $FREQ
do	
	for fw in $FWHM
	do
		BW=${BW_str[$count]}
		if (( $( echo $BW*60.0 '>' $fw | bc -l ) )); then
			cor_win=$( echo $BW*$factor*60.0 | bc -l )
		else
			cor_win=$( echo $fw*$factor | bc -l )
		fi
		echo $fr $fw $cor_win

		case $fw in
		0)
			map1='M'$fr
			map2='MAP';;
		*)	
			map1_0='/users/vasily/data/maps/smoothed_maps/'$fr'_'$fw'_smooth_map.fts'
			map2_0='/users/vasily/data/maps/smoothed_maps/smica_'$fw'_smooth_map.fts'
			map1='map1_0'
			map2='map2_0'
		esac
		
		out_file='/users/vasily/data/maps/corr_maps/mos_corr_'$fr'_'$fw'.fts'

		difmap -cf -1 -o inv_map2 ${!map2}
		difmap -sum -o sum_map ${!map1} inv_map2
		difmap -cr $cor_win -o $out_file sum_map ${!map2}
		echo 'done'

		#cat  big_areas_list_equ | grep -v '^#' |awk -v fr=$fr -v fw=$fw '{printf "./fig/corr_q%s_%s_%s %sd %sd\n", $1, fr, fw, $2, $3}' > coord_list$$
		#f2fig $out_file -fzq1 coord_list$$ -zd $delta'd' -Cs nat
	done
	(( count++ ))
done

#empty_trash	
if [ -f coord_list$$ ]; then rm coord_list$$; fi

