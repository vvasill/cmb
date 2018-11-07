#!/bin/bash

FREQ=$1
FWHM=$2
beamwidth=$3
home_path=$4
eps=$5
mode=$6

BW_str=( $beamwidth )
sigma=1.0
factor_small=1.5

if [ ! -f ./corr ]; then mkdir ./corr; fi
cd ./corr

for fw in $FWHM
do
	cat ../big_areas_list_equ | grep -v '^#' | while read areas_line
	do 
		str1=( $areas_line )
		i=${str1[0]}
		infile='../def_coords/source_lists/big_area_sources_'$i'_'$fw
		outfile='../def_coords/source_lists/test_corr_checked_big_area_sources_'$i'_'$fw
			
		if [ "$mode" == "with" ]
		then		
			echo "with corr mode"
			cat $infile > tmpfile
			count=0
			for fr in $FREQ
			do	
				> re_file

				BW=${BW_str[$count]}
				fw_d=$( echo $fw/60.0 | bc -l )
				if (( $( echo $BW '>' $fw_d | bc -l ) )); then
					delta_small=$( echo $BW*$factor_small | bc -l )
				else
					delta_small=$( echo $fw_d*$factor_small | bc -l )
				fi
				
				echo $i $fr $fw
			
				#loop_on_spots from smica
				cat tmpfile | while read coord_line
				do   
					str2=( $coord_line )	
					spot_num=${str2[0]}
					ra=${str2[3]}
					dec=${str2[4]}
					ra_mc=$(echo $( python ../mc_coord.py $ra $dec ) | cut -d' ' -f1)
					dec_mc=$(echo $( python ../mc_coord.py $ra $dec ) | cut -d' ' -f2)
									
					#checking corr_map
					echo $i'_'$fr'_'$fw'_'$spot_num' '$ra_mc' '$dec_mc > corr_check_coord	
					mapcut $home_path'/maps/corr_maps/mos_corr_'$fr'_'$fw'.fts' -fzq1 corr_check_coord -zd $delta_small'd' -stat > corr_check
					f2fig $home_path'/maps/corr_maps/mos_corr_'$fr'_'$fw'.fts' -fzq1 corr_check_coord -zd $delta_small'd' > /dev/null 2>&1
										
					corr_check_line=$( cat corr_check | tail -1 )
					check_str=( $corr_check_line )
					check_max=${check_str[4]}
					check_max=${check_max/#-/}
					echo $check_max
					if (( $( python ../compare.py $check_max $eps ) ))
					then
						check_corr='yes'
					else
						check_corr='corr_'$fr
					fi

					echo $coord_line' '$check_corr >> re_file
				done
				cat re_file > tmpfile
				(( count++ ))
			done
			cat tmpfile > $outfile
		else
			 awk '{ printf "%s yes\n", $0 }' $infile > $outfile
		fi
	done
done

#empty_trash	
if [ -f re_file ]; then rm re_file; fi
if [ -f tmpfile ]; then rm tmpfile; fi
