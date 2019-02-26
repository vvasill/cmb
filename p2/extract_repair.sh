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

cd ./big_areas

FREQ=$1
FWHM=$2
factor=1.5
sigma=1.0

for fr in $FREQ
do
	for fw in $FWHM
	do
		cat ../big_areas_list_equ | grep -v '^#' | while read areas_line
		do 
			#names def
			str1=( $areas_line )
			i=${str1[0]}

			stat_input='stat_output_'$i'_'$fr'_'$fw
			outfile='./source_lists/big_area_sources_'$i'_'$fr'_'$fw
			> $outfile
			sed -i -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' $stat_input
			sed -i -e 's/,//g' $stat_input

			count=1
			cat $stat_input | while read line
			do
				if (( ! $( echo $count'%'4 | bc ) ))
				then
					str=( $line )
					ra=${str[2]}
					dec=${str[3]}
					t=${str[4]}
				fi
				if (( ! $( echo $count'%'5 | bc ) ))
				then
					str=( $line )
					name=${str[0]}
					echo $name' '$ra' '$dec' '$t >> $output
					count=0
				fi
				(( count++ ))
			done
		done
	done
done

