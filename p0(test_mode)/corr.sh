#!/bin/bash

FREQ=$1
FWHM=$2

cd ./out_data

for fr in $FREQ
do
	for fw in $FWHM
	do
		#flux calibration
		calib_res=( $( cat ../calib_res | grep 'fr_'$fr | grep 'fw_'$fw ) )
		a=${calib_res[2]}
		b=${calib_res[3]}
		file_in='extra_calib_data_'$fr'_'$fw
		awk -v a=$a -v b=$b '{printf "%s %s %s %s\n", (a*$2+b), (a*$3), $4, $5}' $file_in > 'calib_calib_data_'$fr'_'$fw

		#graph
		fn_in='calib_calib_data_'$fr'_'$fw
		fn_out_gif='../graphs/corr_'$fr'_'$fw'.gif'	
		fn_out_eps_wb='../graphs/corr_'$fr'_'$fw'_wb.eps'
		gnuplot -e "fn_in='$fn_in'" -e "fn_out_gif='$fn_out_gif'" -e "fn_out_eps_wb='$fn_out_eps_wb'" ../graph_corr > /dev/null 2>&1
	done	
done

