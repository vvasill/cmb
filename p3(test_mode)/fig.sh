#!/bin/bash

FREQ=$1
FWHM=$2
beamwidth=$3
home_path=$4
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

			#sources_info_extracting: coords and fluxes
			cat ./Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "./figs/%s_%s_%s_%s %s %s\n", $1, num, fr, fw, $3, $4}' > coord_flux_list$$
			echo 'sources are available: '$( cat coord_flux_list$$ | wc -l )
			#coord_flux_list: name, ra_h, dec_h
		
			#loop on PLANCK sources
			cat coord_flux_list$$ | while read coord_line
			do
				#create a fig of small areas	
				echo $coord_line > coord_line$$
				echo $coord_line
				f2fig  ${!MAP} -fzq1 coord_line$$ -zd $delta_small'd' -Cs nat > /dev/null 2>&1
			done
		done
	done
	(( count++ ))
done

#empty_trash	
if [ -f coord_line$$ ]; then rm coord_line$$; fi
if [ -f coord_flux_list$$ ]; then rm coord_flux_list$$; fi
