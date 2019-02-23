#!/bin/bash

FREQ=$1
FWHM=$2
beamwidth=$3
home_path=$4
mode=$5

factor=1.5
sigma=1.0
delta=20.0

BW_str=( $beamwidth )
sxt_config='./sxt_config/config'	

#############################################################################

M030=$home_path'/maps/m_030_R2.01.fts'
M044=$home_path'/maps/m_044_R2.01.fts'
M070=$home_path'/maps/m_070_R2.01.fts'
M100=$home_path'/maps/m_100_R2.02.fts'
M143=$home_path'/maps/m_143_R2.02.fts'
M217=$home_path'/maps/m_217_R2.02.fts'
M353=$home_path'/maps/m_353_R2.02.fts'
M545=$home_path'/maps/m_545_R2.02.fts'
M857=$home_path'/maps/m_857_R2.02.fts'

if [ ! -d ./out_data ]; then mkdir ./out_data; fi
if [ ! -d ./small_areas ]; then mkdir ./small_areas; fi
if [ ! -d ./temp ]; then mkdir ./temp; fi

coord_list=./temp/coord_list$$
flux_list=./temp/flux_list$$
flux_coord_list=./temp/flux_coord_list$$
flux_coord_list_controled=./temp/flux_coord_list_controled
decimal_coord_list=./temp/decimal_coord_list$$
skipped=./out_data/skipped_names_1
all=./out_data/all_sources
controled_list=./out_data/controled_list

> $skipped
> $all
> $controled_list

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
		outfile='./out_data/data_'$fr'_'$fw
		>$outfile

		#set path to current map
		case $fw in
		0)
			MAP='M'$fr;;
		*)
			MAP_0=$home_path'/maps/smoothed_maps/'$fr'_'$fw'_smooth_map.fts'
			MAP='MAP_0';;
		esac

		#loop_on_big_areas
		cat ./big_areas_list_equ | grep -v '^#' | while read line
		do 
			#names def
			ba_str=( $line )
			i=${ba_str[0]}
			area_num='area_'$i'.0'
			echo "freq: $fr big area: $i FWHM: $fw"

			### sources_info_extracting: coords and fluxes ###
			#coord_list: name, ra_h, dec_h
			#coord_flux_list: name, flux, flux_err, ra, dec
			cat ./Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s %s %s\n", $1, num, fr, fw, $3, $4}' > $coord_list
			cat ./Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s %s %s %s %s\n", $1, num, fr, fw, $6, $7, ($8*15.0), $9}' > $flux_coord_list
			echo 'sources are available: '$( cat $flux_coord_list | wc -l )
		
			### cutting small areas and figs plotting ###
			#./small_areas_cut.sh ${!MAP} $coord_list $small_delta

			### checking, if figure is good ###
			>$flux_coord_list_controled
			./fig_check.sh $flux_coord_list $flux_coord_list_controled $mode
			cat $flux_coord_list_controled >> $controled_list

			### extracting integral temperatures ###
			#loop_on_sources
			cat $flux_coord_list_controled | grep 'flag_y' | while read line
			do
				#coords and names def
				fc_str=( $line )
				source_name=${fc_str[0]}
				fits_name='./small_areas/'${fc_str[0]}'.fts'
				flux=${fc_str[1]}
				flux_err=${fc_str[2]}
				ra_c=${fc_str[3]}
				dec_c=${fc_str[4]}			
					
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
	done
	(( count++ ))
done

#empty_trash
if [ -d ./temp ]; then rm -r ./temp; fi
if [ -f sxt_output ]; then rm sxt_output; fi
if [ -f sxt_tmp ]; then rm sxt_tmp; fi
