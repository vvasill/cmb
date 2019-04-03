#!/bin/bash

delta="20.0"

FREQ=$1
FWHM=$2
beamwidth=$3
mode=$4
sigma=$5

BW_str=( $beamwidth )
factor=1.5

cd ./match
temp_outfile=../temp/temp_outfile$$
skipped=skipped
> $skipped

for fw in $FWHM
do
	#loop_on_big_areas
	cat ../big_areas_list_equ | grep -v '^#' | while read areas_line
	do 
		#names def
		str_ba=( $areas_line )
		i=${str_ba[0]}
		infile_2='../def_coords/source_lists/corr_checked_big_area_sources_'$i'_'$fw
					
		count=0
		for fr in $FREQ
		do
			#names def
			BW=${BW_str[$count]}
			fw_d=$( echo $fw/60.0 | bc -l )
			if (( $( echo $BW '>' $fw_d | bc -l ) ))
			then
				delta_small=$( echo $BW*$factor | bc )
			else
				delta_small=$( echo $fw_d*$factor | bc -l)
			fi
			
			if [ "$mode" == "T" ]
			then
				infile_1='../big_areas/source_lists/'$sigma'/T_big_area_sources_'$i'_'$fr'_'$fw
				outfile='T_outfile_'$i'_'$fr'_'$fw'_'$sigma
			fi
			if [ "$mode" == "A" ]
			then 
				infile_1='../big_areas/source_lists/'$sigma'/A_big_area_sources_'$i'_'$fr'_'$fw
				outfile='A_outfile_'$i'_'$fr'_'$fw'_'$sigma
			fi 
			if [ "$mode" == "S" ]
			then 
				infile_1='../big_areas/source_lists/'$sigma'/S_big_area_sources_'$i'_'$fr'_'$fw
				outfile='S_outfile_'$i'_'$fr'_'$fw'_'$sigma
			fi 

			> $outfile
			echo $i'_'$fr'_'$fw
		
			#loop_on_spots from smica
			cat $infile_2 | grep -v 'corr_'$fr | while read coord_line
			do  
				> $temp_outfile
				str_ssp=( $coord_line )	
				spot_num=${str_ssp[0]}
				ra=${str_ssp[3]}
				dec=${str_ssp[4]}
				
				ra_l=$( echo $ra - $delta_small*0.5 | bc -l )
				ra_r=$( echo $ra + $delta_small*0.5 | bc -l )
				dec_l=$( echo $dec - $delta_small*0.5 | bc -l )
				dec_r=$( echo $dec + $delta_small*0.5 | bc -l )
				
				#checking, if source (from sources on big areas) is included in small_area (across spot on SMICA map)
				awk -v ra=$ra -v dec=$dec -v ra_l=$ra_l -v ra_r=$ra_r -v dec_l=$dec_l -v dec_r=$dec_r -v spot_num=$spot_num '{if ($4 > ra_l && $4 < ra_r && $5 > dec_l && $5 < dec_r) {printf "%s %s %s %s %s\n", spot_num, $2, $3, ra, dec}}' $infile_1 >> $temp_outfile
									
				#some output_file_modifications: merging if more than one peaks on one spot
				cat $temp_outfile | ( 
					t=0
					t_err=0
					while read temp_line
					do
						str_sl=( $temp_line )	
						name=${str_sl[0]}	
						dt=${str_sl[1]}
						dt_err=${str_sl[2]}	

						if [ "$mode" == "T" ]
						then	
							### find maximum ###
							if (( $( echo $dt '>' $t | bc -l ) )); then t=$dt; fi
							t_err=$dt_err
						fi
						if [ "$mode" == "A" ]
						then	
							### find maximum ###
							if (( $( echo $dt '>' $t | bc -l ) )); then t=$dt; fi
							t_err=$dt_err
						fi
						if [ "$mode" == "S" ]
						then	
							### sum all peaks ###
							t=$( echo $t + $dt | bc )
							t_err=$( echo "sqrt($t_err*$t_err + $dt_err*$dt_err)" | bc -l )
						fi

					done	
					if [ "$t" != "0" ]
					then 
						echo $name' '$t' '$t_err' '$ra' '$dec >> $outfile
					else
						echo $fr' '$fw' '$spot_num >> $skipped
					fi
				)	
			done
		echo $count $delta_small
		(( count++ ))
		done
	done
done

#empty_trash	
if [ -f $temp_outfile ]; then rm $temp_outfile; fi
