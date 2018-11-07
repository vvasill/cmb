#!/bin/bash

FREQ=$1
FWHM=$2
home_path=$3
mode=$4

echo "0 0 0 5 5 35 35 60 60" > fwhm_line

for fr in $FREQ
do	
	outfile='./res/extract_'$fr
	> $outfile
	./join_all.sh './in_data/calib_'$fr'_60' './in_data/calib_'$fr'_35' './in_data/calib_'$fr'_5' './in_data/calib_'$fr'_0' > $outfile
	cat $outfile
	cat $outfile | grep -v " 0.0 0.0 " > $outfile

	cat $outfile | grep "31999_1" > file_in
	cat fwhm_line file_in > tmp && mv tmp file_in

	#deleting first column
	awk '{$1 = ""; print $i}' file_in > tmp 
	awk '{for (i=1; i<=NF; i++) if (i % 2) printf "%s", $i (i == NF || i == (NF-1)?"\n":" ")}' tmp > './res/flux_'$fr
	num=$( cat './res/flux_'$fr | wc -l )
	echo $num
	awk '{$1 = ""; $2 = ""; print $i}' file_in > tmp
	awk '{for (i=1; i<=NF; i++) if (i % 2) printf "%s", $i (i == NF || i == (NF-1)?"\n":" ")}' tmp > './res/flux_err_'$fr

	python file_rotate.py './res/flux_'$fr './res/rotated_flux_'$fr './res/av_'$fr './res/flux_err_'$fr './res/rotated_flux_err_'$fr './res/av_error_'$fr
	awk 'FNR==NR{a[$1]=$2;b[$1]=$3;next} ($1 in a) {print $0,a[$1],b[$1]}' './res/flux_'$fr './res/flux_err_'$fr > './res/'$fw	

	fn_in='./res/'$fw
	fn_out_gif='./res/'$fw'.gif'
	gnuplot -e "fn_in='$fn_in'" -e "fn_out_gif='$fn_out_gif'" graph
done
