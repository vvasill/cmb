#!/bin/bash

cd ./big_areas
if [ ! -f ./source_lists ]; then mkdir ./source_lists; fi

FREQ=$1
FWHM=$2
beamwidth=$3

factor=1.5
sigma=1.0
delta=20.0
BW_str=( $beamwidth )

#loop_on_freq
count=0
for fr in $FREQ
do	
	for fw in $FWHM
	do
		BW=${BW_str[$count]}
		fw_d=$( echo $fw/60.0 | bc -l )
		if (( $( echo $BW '>' $fw_d | bc -l ) )); then
			delta_small=$( echo $BW*$factor | bc -l )
		else
			delta_small=$( echo $fw_d*$factor | bc -l)
		fi

		#loop_on_big_areas
		cat ../big_areas_list_equ_norm | grep -v '^#' | while read areas_line
		do 
			#names def
			str1=( $areas_line )
			i=${str1[0]}
			ra_center=${str1[1]}
			dec_center=${str1[2]}
			MAP='q'$i'_'$fr'_'$fw'_'$delta'.fts'
			outfile='./source_lists/T_big_area_sources_'$i'_'$fr'_'$fw
			> $outfile

			name=$i'_'$fr'_'$fw
			echo $i'_'$fr'_'$fw
			
			../a_extract.pyc $MAP $delta $delta_small $ra_center $dec_center $name $sigma >> $outfile
			awk 'BEGIN{CONVFMT="%.9f"}{for(i=1; i<=NF; i++)if($i~/^[0-9]+([eE][+-][0-9]+)?/)$i+=0;}1' $outfile > tmp && mv tmp $outfile
		done
	done
	(( count++ ))
done
