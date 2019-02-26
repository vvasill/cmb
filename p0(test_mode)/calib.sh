#!/bin/bash

FREQ=$1
FWHM=$2
home_path=$3

> calib_res
if [ ! -f graphs ]; then mkdir graphs; fi
> ./out_data/skipped_names_00

for fr in $FREQ
do	
	for fw in $FWHM
	do
		file_name='./out_data/calib_data_'$fr'_'$fw
		file_name_extra='./out_data/extra_calib_data_'$fr'_'$fw
		fn_out_gif='./graphs/'$fr'_'$fw'.gif'
		fn_out_eps_wb='./graphs/'$fr'_'$fw'_wb.eps'

		#reject nulls
		grep -v " 0.0 0.0 " $file_name > tmp 
		grep " 0.0 0.0 " $file_name >> ./out_data/skipped_names_00
		mv tmp $file_name
		grep -v " 0 0 " $file_name > tmp 
		grep " 0 0 " $file_name >> ./out_data/skipped_names_00
		mv tmp $file_name
		
		awk '{print $4}' $file_name > flux
		awk '{print $2}' $file_name > temp

		#awk '{print $5}' $file_name > flux_err
		#awk '{print $3}' $file_name > temp_err
		#python stat.py ./temp ./flux ./temp_err ./flux_err $a $b $file_name_extra

		#reject some points with small flux and large temp
		max_flux=$( awk -F= 'BEGIN { max = -inf } { if ($1 > max) { max = $1 } } END { print max }' flux )
		max_temp=$( awk -F= 'BEGIN { max = -inf } { if ($1 > max) { max = $1 } } END { print max }' temp )
		num=$( cat $file_name | wc -l )
		echo $fr $fw $num
		cat $file_name | awk -v max_temp=$max_temp -v max_flux=$max_flux '{ if (! (($2 > 0.1*max_temp) && ($4 < 0.1*max_flux)) ) { print $0 } }' > $file_name_extra
		#cat $file_name > $file_name_extra	
		num=$( cat $file_name_extra | wc -l )
		echo $fr $fw $num
				
		#lstsq approximation
		a=$(echo $(python calib.py $file_name_extra) | cut -d' ' -f1)
		b=$(echo $(python calib.py $file_name_extra) | cut -d' ' -f2)

		#graph
		gnuplot -e "fn_in='$file_name_extra'" -e "fn_out_gif='$fn_out_gif'" -e "fn_out_eps_wb='$fn_out_eps_wb'" -e "a='$a'" -e "b='$b'" graph > /dev/null 2>&1

		echo 'fr_'$fr' fw_'$fw' '$a' '$b >> calib_res
	done
done

#cp calib_res $home_path'/calib_res'
