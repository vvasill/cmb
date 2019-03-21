#!/bin/bash

FREQ=$1
FWHM=$2
sigma=$3

factor=1.5
BW_str=( $beamwidth )
sxt_config='./sxt_config/config'	

flux_coord_list_controled=./out_data/flux_coord_list_controled
skipped=./out_data/skipped_names_1
all=./out_data/all_sources
> $skipped
> $all

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
		outfile='./source_lists/'$sigma'/S_big_area_sources_'$i'_'$fr'_'$fw
		> $outfile

		echo "freq: $fr FWHM: $fw"

		### extracting integral temperatures ###
		#loop_on_sources
		cat $flux_coord_list_controled | grep 'fr_'$fr | grep 'fw_'$fw | grep 'flag_y' | while read line
		do
			#coords and names def
			fc_str=( $line )
			source_name=${fc_str[0]}
			fits_name='./small_areas/'$source_name'.fts'
			flux=${fc_str[3]}
			flux_err=${fc_str[4]}
			ra_c=${fc_str[5]}
			dec_c=${fc_str[6]}			
					
			#SExtractor processing
			sextractor $fits_name -c $sxt_config -DETECT_THRESH $sigma -ANALYSIS_THRESH $sigma > /dev/null 2>&1

			#list of all sextractions
			cat sxt_output >> $all
			#avoiding problems with exponential format
			awk 'BEGIN{CONVFMT="%.9f"}{for(i=1; i<=NF; i++)if($i~/^[0-9]+([eE][+-][0-9]+)?/)$i+=0;}1' sxt_output > ./temp/sxt_tmp
			sed -i 	-e 's/+//g' ./temp/sxt_tmp

			#sex_output_file_modifications: merging if more than one source in small_area
			if [ -s ./temp/sxt_tmp ]; then
				cat ./temp/sxt_tmp | ( 
				t=0
				t_err=0

					while read sxt_line
					do
						sxt_str=( $sxt_line )		
						dt=${sxt_str[1]}
						dt_err=${sxt_str[2]}
						ra=${sxt_str[3]}
						dec=${sxt_str[4]}
						
						len1=$( echo "sqrt( ($ra - $ra_c)*($ra - $ra_c) + ($dec - $dec_c)*($dec - $dec_c) )" | bc -l )
						len2=$( echo "$delta_small*0.5" | bc -l )
						
						if (( $( echo $len1'<'$len2 | bc -l ) ))
						then
							t=$( echo $t + $dt | bc -l )
							t_err=$( echo "sqrt($t_err*$t_err + $dt_err*$dt_err)" | bc -l )
						else 
							echo $source_name >> $skipped
						fi
					done	

				if [ "$t" != "0" ]; then echo $source_name' '$t' '$t_err' '$flux' '$flux_err >> $outfile; fi
				)
			fi
		done
	done
	(( count++ ))
done

#empty_trash
if [ -f sxt_output ]; then rm sxt_output; fi
