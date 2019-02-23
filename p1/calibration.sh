#!/bin/bash

FREQ=$1
FWHM=$2
home_path=$3
mode=$4

if [ ! -d graphs ]; then mkdir graphs; fi
if [ ! -d temp ]; then mkdir temp; fi

skipped='./out_data/skipped_names_2'
flux=./temp/flux
flux_err=./temp/flux_err
temp=./temp/temp
temp_err=./temp/temp_err

> ./calib_res
> $skipped

for fr in $FREQ
do	
	for fw in $FWHM
	do
		infile='./out_data/data_'$fr'_'$fw
		final_data='./out_data/final_data_'$fr'_'$fw
		outfile_gif='./graphs/'$fr'_'$fw'.gif'
		outfile_eps_wb='./graphs/'$fr'_'$fw'_wb.eps'
		
		awk '{print $2}' $infile > $temp
		awk '{print $3}' $infile > $temp_err
		awk '{print $4}' $infile > $flux
		awk '{print $5}' $infile > $flux_err

		#python stat.py $temp $flux $temp_err $flux_err $a $b $final_data

		if [ "$mode" == "control" ]; then
			cat $infile > $final_data
		fi
		if [ "$mode" == "auto" ]; then
			#reject some points with small flux and large temp
			max_flux=$( awk -F= 'BEGIN { max = -inf } { if ($1 > max) { max = $1 } } END { print max }' $flux )
			max_temp=$( awk -F= 'BEGIN { max = -inf } { if ($1 > max) { max = $1 } } END { print max }' $temp )
			num=$( cat $infile | wc -l )
			echo $fr $fw $num
			awk -v max_temp=$max_temp -v max_flux=$max_flux '{ if (! (($2 > 0.1*max_temp) && ($4 < 0.1*max_flux)) ) { print $0 } }' $infile > $final_data	
			num=$( cat $final_data | wc -l )
			echo $fr $fw $num
		fi
				
		### lstsq approximation ###
		a=$(echo $(python calibration.py $final_data) | cut -d' ' -f1)
		b=$(echo $(python calibration.py $final_data) | cut -d' ' -f2)

		### graph ###
		gnuplot -e "infile='$final_data'" -e "outfile_gif='$outfile_gif'" -e "outfile_eps_wb='$outfile_eps_wb'" -e "a='$a'" -e "b='$b'" graph >/dev/null 2>&1

		echo 'fr_'$fr' fw_'$fw' '$a' '$b >> calib_res
	done
done

