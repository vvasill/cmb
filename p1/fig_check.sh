#!/bin/bash

### visual checking if source is good for calibration ###


FREQ=$1
FWHM=$2
home_path=$3
mode=$4

flux_coord_list=./temp/flux_coord_list$$
flux_coord_list_controled=./out_data/flux_coord_list_controled
coord_line=./temp/coord_line$$
skipped=./out_data/skipped_names_checking
> $flux_coord_list_controled
> $skipped

#loop_on_freq
count=0
for fr in $FREQ
do
	#loop_on_smoothing_angles
	for fw in $FWHM
	do
		#loop_on_big_areas
		cat ./big_areas_list_equ | grep -v '^#' | while read line
		do
			#names def
			ba_str=( $line )
			i=${ba_str[0]}
			area_num='area_'$i'.0'
			echo "freq: $fr big area: $i FWHM: $fw"

			### sources_info_extracting: coords and fluxes ###
			#flux_coord_list: name, flux, flux_err, ra_h, dec_h
			cat ./Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s fr_%s fw_%s %s %s %s %s\n", $1, num, fr, fr, fw, $6, $7, ($8*15.0), $9}' > $flux_coord_list
			echo 'sources are available: '$( cat $flux_coord_list | wc -l )	

			cat $flux_coord_list | while read line
			do					
				echo $line > $coord_line
				fc_str=( $line )
				source_name=${fc_str[0]}
		
				if [ "$mode" == "control" ]; then
					echo 'source: '$source_name'_'$fw
					convert -append './figs/'$source_name'_'$fw'.gif' './figs/'$source_name'_5.gif' out.jpg
					eog out.jpg & fig_pid=$!
		
					echo "Is it a good source?"
					read flag </dev/tty

					if [ -n "$fig_pid" -a -e /proc/$fig_pid ]; then
						kill $fig_pid
					fi
				fi
				if [ "$mode" == "auto" ]; then
					flag='y'
				fi
			
				awk -v flag=$flag -v fw=$fw '{printf "%s_%s %s %s %s %s %s %s flag_%s\n", $1, fw, $2, $3, $4, $5, $6, $7, flag}' $coord_line >> $flux_coord_list_controled
				if [ "$flag" == "n" ]; then echo $source_name'_'$fw >> $skipped; fi	
			done
		done
	done
done

#empty_trash
if [ -d ./temp ]; then rm -r ./temp; fi
if [ -f out.jpg ]; then rm out.jpg; fi
