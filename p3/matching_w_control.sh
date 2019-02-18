#!/bin/bash

FREQ=$1
FWHM=$2
beamwidth=$3
sigma=1.0
factor=1.5
BW_str=( $beamwidth )

M030=$home_path'/maps/m_030_R2.01.fts'
M044=$home_path'/maps/m_044_R2.01.fts'
M070=$home_path'/maps/m_070_R2.01.fts'
M100=$home_path'/maps/m_100_R2.02.fts'
M143=$home_path'/maps/m_143_R2.02.fts'
M217=$home_path'/maps/m_217_R2.02.fts'
M353=$home_path'/maps/m_353_R2.02.fts'
M545=$home_path'/maps/m_545_R2.02.fts'
M857=$home_path'/maps/m_857_R2.02.fts'

check_dir='./out_data'
if [ ! -f $check_dir ]; then mkdir $check_dir; fi
check_dir='./figs'
if [ ! -f $check_dir ]; then mkdir $check_dir; fi
> skipped_names

#loop_on_freq
count=0
for fr in $FREQ
do
	#loop_on_smoothing_angles
	for fw in $FWHM
	do
		#names def
		BW=${BW_str[$count]}
		fw_d=$( echo $fw/60.0 | bc -l )
		if (( $( echo $BW '>' $fw_d | bc -l ) ))
		then
			delta_small=$( echo $BW*$factor | bc -l )
		else
			delta_small=$( echo $fw_d*$factor | bc -l )
		fi

		outfile='./out_data/calib_data_'$fr'_'$fw
		> $outfile

		#set path to current map
		case $fw in
		0)
			MAP='M'$fr;;
		*)
			MAP_0=$home_path'/maps/smoothed_maps/'$fr'_'$fw'_smooth_map.fts'
			MAP='MAP_0';;
		esac

		#loop_on_big_areas
		cat ./big_areas_list_equ | grep -v '^#' | while read areas_line
		do 
			#names def
			str1=( $areas_line )
			i=${str1[0]}
			area_num='area_'$i'.0'
			echo $i'_'$fr'_'$fw
			big_area_sources='./big_areas/source_lists/big_area_sources_'$i'_'$fr'_'$fw	

			#sources_info_extracting: coords and fluxes
			cat ./Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s %s %s %s %s %s %s\n", $1, num, fr, fw, $6, $7, ($8*15.0), $3, $4}' > coord_flux_list$$
			echo 'sources are available: '$( cat coord_flux_list$$ | wc -l )
			#coord_flux_list: name, flux, flux_err, ra, dec
		
			#loop on PLANCK sources
			cat coord_flux_list$$ | while read coord_line
			do
				> temp_outfile
				p_str=( $coord_line )	
				source_name=${p_str[0]}
				flux=${p_str[1]}
				flux_err=${p_str[2]}
				ra=${p_str[3]}
				dec=${p_str[4]}
				ra_h=${p_str[5]}
				dec_h=${p_str[6]}
				
				ra_l=$( echo $ra - $delta_small | bc -l )
				ra_r=$( echo $ra + $delta_small | bc -l )
				dec_l=$( echo $dec - $delta_small | bc -l )
				dec_r=$( echo $dec + $delta_small | bc -l )

				#create a fig of small areas	
				cat './figs/'$source_name' '$ra_h' '$dec_h > coord_line$$
				f2fig  ${!MAP} -fzq1 coord_line$$ -zd $delta_small'd' -Cs nat #> /dev/null 2>&1
				shotwell './figs/'$source_name'.gif'

				read -p "Is it a good source?" -r
				pkill -P $$
				if [[ $REPLY =~ ^[Yy]$ ]]; then
					#checking, if some sources from big_area_list are included in small_area across PLANCK source
					awk -v ra_l=$ra_l -v ra_r=$ra_r -v dec_l=$dec_l -v dec_r=$dec_r '{if ($4 > ra_l && $4 < ra_r && $5 > dec_l && $5 < dec_r) {printf "%s %s\n", $2, $3}}' $big_area_sources >> temp_outfile
									
					if [ -s temp_outfile ]; then
						#some output_file_modifications: merging if more than one peaks on one spot
						cat temp_outfile | ( 
							t=0
							t_err=0
	
							while read temp_line
							do
								t_str=( $temp_line )	
								dt=${t_str[0]}
								dt_err=${t_str[1]}	

								### sum all peaks ###
								t=$( echo $t + $dt | bc )
								t_err=$( echo "sqrt($t_err*$t_err + $dt_err*$dt_err)" | bc -l )
							done	

							echo $source_name' '$t' '$t_err' '$flux' '$flux_err >> $outfile
						)	
					fi
				else
					echo $source_name >> skipped_names
				fi
			done
		done
	done
	(( count++ ))
done

#empty_trash	
if [ -f temp_outfile ]; then rm temp_outfile; fi
if [ -f coord_line$$ ]; then rm coord_line$$; fi
if [ -f coord_flux_list$$ ]; then rm coord_flux_list$$; fi
if [ -f calib_data$$ ]; then rm calib_data$$; fi	
