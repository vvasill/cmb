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

FREQ=$1
FWHM=$2
beamwidth=$3
home_path=$4

factor=1.5
sigma=1.0
outfile='../out_data/calib_data_'$fr'_'$fw	

> ./out_data/skipped_names
> ./out_data/small_areas_sources
if [ ! -f ./out_data ]; then mkdir ./out_data; fi
if [ ! -f ./small_areas ]; then mkdir ./small_areas; fi
cd ./small_areas

#loop_on_freq
count=0
for fr in $FREQ
do
	#loop_on_smoothing_angles
	for fw in $FWHM
	do
		#set a size of small area for current fw/freq and map/smoothed map
		BW_str=( $beamwidth )
		BW=${BW_str[$count]}

		fw_d=$( echo $fw/60.0 | bc -l )
		if (( $( echo $BW '>' $fw_d | bc -l ) )); then
			delta=$( echo $BW*$factor | bc -l )
		else
			delta=$( echo $fw_d*$factor | bc -l)
		fi
		echo $delta

		#set path to current map
		case $fw in
		0)
			MAP='M'$fr;;
		*)
			MAP_0=$home_path'/maps/smoothed_maps/'$fr'_'$fw'_smooth_map.fts'
			MAP='MAP_0';;
		esac

		#loop_on_big_areas
		cat /users/vasily/data/big_areas_list | grep -v '^#' | while read areas_line
		do 
			#names def
			str1=( $areas_line )
			i=${str1[0]}
			area_num='area_'$i'.0'
			echo "freq: $fr big area: $i FWHM: $fw"

			#sources_info_extracting: coords, coords in decimal format, fluxes
			cat ../Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s %s %s\n", $1, num, fr, fw, $3, $4}' > coord_list$$
			cat ../Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s %s %s\n", $1, num, fr, fw, ($8*15.0), $9}' > decimal_coord_list$$
			cat ../Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s %s %s\n", $1, num, fr, fw, $6, $7}' > flux_list$$
			echo 'sources are available: '$(cat coord_list$$ | wc -l )

			#loop_on_sources		

			#cutting small areas	
			cat coord_list$$ | while read line
			do
				echo $line > coord_line$$
				f2fig  ${!MAP} -fzq1 coord_line$$ -zd $delta'd' -Cs nat > /dev/null 2>&1
				mapcut ${!MAP} -fzq1 coord_line$$ -zd $delta'd' > /dev/null 2>&1
			done

			#extracting integral temperatures
			cat decimal_coord_list$$ | while read line
			do
				#coords and names def
				echo $line > coord_line$$
				str=( $line )
				name=${str[0]}
				fits_name=$name'.fts'
				ra_c=${str[1]}
				dec_c=${str[2]}			
					
				#SExtractor processing
				sextractor $fits_name -c ../sex_config/config -DETECT_THRESH $sigma -ANALYSIS_THRESH $sigma > /dev/null 2>&1

				#list of all sextractions
				cat sex_output >> ../out_data/small_areas_sources
				#avoiding problems with exponential format
				awk 'BEGIN{CONVFMT="%.9f"}{for(i=1; i<=NF; i++)if($i~/^[0-9]+([eE][+-][0-9]+)?/)$i+=0;}1' sex_output > tmp && mv tmp sex_output 
				sed -i -e 's/+//g' sex_output

				#sex_output_file_modifications: merging if more than one source in small_area
				if [ -s sex_output ]; then
				cat sex_output | ( 
					t=0
					t_err=0

					while read sex_line
					do
						str=( $sex_line )		
						dt=${str[1]}
						dt_err=${str[2]}
						ra=${str[3]}
						dec=${str[4]}
						len1=$( echo "sqrt( ($ra - $ra_c)*($ra - $ra_c) + ($dec - $dec_c)*($dec - $dec_c) )" | bc -l )
						len2=$( echo "$delta*0.5" | bc -l )
						
						if (( $( echo $len1'<'$len2 | bc -l ) ))
						then
							t=$(echo $t + $dt | bc)
							t_err=$( echo "sqrt($t_err*$t_err + $dt_err*$dt_err)" | bc -l )
						else 
							echo $name >> ../out_data/skipped_names
						fi
					done	
	
					echo $name' '$t' '$t_err >> calib_data$$
				)
				fi
			done
		done

		#merging Planck_fluxes and sextractor output in one file
		awk 'FNR==NR{a[$1]=$2;b[$1]=$3;next} ($1 in a) {print $0,a[$1],b[$1]}' flux_list$$ calib_data$$ > $outfile
	
		#empty file for new freq
		> calib_data$$
	done
	(( count++ ))
done

#empty_trash
if [ -f coord_list$$ ]; then rm coord_list$$; fi
if [ -f coord_line$$ ]; then rm coord_line$$; fi
if [ -f decimal_coord_list$$ ]; then rm decimal_coord_list$$; fi
if [ -f flux_list$$ ]; then rm flux_list$$; fi
if [ -f sex_output ]; then rm sex_output; fi	
if [ -f calib_data$$ ]; then rm calib_data$$; fi	

