#!/bin/bash

FWHM=$1
mode=$2
home_path=$3

if [ ! -f graphs ]; then mkdir graphs; fi
if [ "$mode" == "T" ]
then
	#in
	in='./res/T_flux_'
	err_in='./res/T_flux_err_'
	#out
	rot='./res/rotated_T_flux_'
	rot_err='./res/rotated_T_flux_err_'
	av='./res/T_av_'
	av_err='./res/T_av_error_'
	out='./res/T_'
	out_graph='./graphs/T_'
	y_label='{/Helvetica-Italic T}, K'
fi
if [ "$mode" == "S" ]
then
	#in
	in='./res/S_flux_'
	err_in='./res/S_flux_err_'
	#out
	rot='./res/rotated_S_flux_'
	rot_err='./res/rotated_S_flux_err_'
	av='./res/S_av_'
	av_err='./res/S_av_error_'
	out='./res/S_'
	out_graph='./graphs/S_'
	y_label='{/Helvetica-Italic S}, Ja'
fi

for fw in $FWHM
do	
	num=$( cat $in$fw | wc -l )
	echo $num	
	
	### rotating and averaging ###
	python file_rotate.py $in$fw $rot$fw $av$fw $err_in$fw $rot_err$fw $av_err$fw
	#join flux and error
	join -1 1 -2 1 $av$fw $av_err$fw > $out$fw

	### plotting ###
	fn_in=$out$fw
	fn_out_eps_wb=$out_graph$fw'_wb.eps'
	fn_out_gif=$out_graph$fw'.gif'	
	fn_out_png=$out_graph$fw'.png'

	gnuplot -e "fn_out_gif='$fn_out_gif'" -e "fn_out_png='$fn_out_png'" -e "fn_out_eps_wb='$fn_out_eps_wb'" -e "fn_in='$fn_in'" -e "y_label='$y_label'" many_graph

done

#empty_trash
for file in $rot*
do
	if [ -f $file ]; then rm $file; fi
done
for file in $av*
do
	if [ -f $file ]; then rm $file; fi	
done
