#!/bin/bash

FREQ=$1
FWHM=$2

FREQ="030 044 070 100 143 217"
echo "0 0 0 5 5 35 35 60 60" > fwhm_line

for fr in $FREQ
do	
	filein='./res/extract_'$fr
	cat fwhm_line $filein > tmp && mv tmp filein

	#deleting first column
	awk '{$1 = ""; print $i}' filein > tmp 
	awk '{for (i=1; i<=NF; i++) if (i % 2) printf "%s", $i (i == NF || i == (NF-1)?"\n":" ")}' tmp > './res/flux_'$fr
	awk '{$1 = ""; $2 = ""; print $i}' filein > tmp
	awk '{for (i=1; i<=NF; i++) if (i % 2) printf "%s", $i (i == NF || i == (NF-1)?"\n":" ")}' tmp > './res/flux_err_'$fr

	num=$( cat './res/flux_'$fr | wc -l )
	(( num-- ))

	python file_rotate.py './res/flux_'$fr './res/rotated_flux_'$fr './res/flux_err_'$fr './res/rotated_flux_err_'$fr
	awk 'FNR==NR{a[$1]=$2;next} ($1 in a) {print $1,$2,a[$1]}' './res/rotated_flux_err_'$fr './res/rotated_flux_'$fr > './res/res'	

	fn_in='./res/rotated_flux_'$fr
	fn_out_gif='./res/res_'$fr'.gif'
	gnuplot -e "fn_in='$fn_in'" -e "fn_out_gif='$fn_out_gif'" -e "num='$num'" many_graph
done

rm filein
rm tmp
