#!/bin/bash

FWHM=$1
mode=$2
home_path=$3
if [ ! -f graphs ]; then mkdir graphs; fi

for fw in $FWHM
do
	num=$( cat './res/flux_'$fw | wc -l )
	echo $num

	#rotating
	python file_rotate.py './res/flux_'$fw './res/rotated_flux_'$fw './res/av_'$fw './res/flux_err_'$fw './res/rotated_flux_err_'$fw './res/av_error_'$fw
	awk 'FNR==NR{a[$1]=$2;b[$1]=$3;next} ($1 in a) {print $0,a[$1],b[$1]}' './res/av_error_'$fw './res/av_'$fw > './res/'$fw

	#graph plotting
	fn_out_png='./graphs/'$fw'.png'
	fn_in='./res/'$fw
	
	if [ "$mode" == "T" ]
	then		
		y_label="T, K"
		fn_out_eps_wb='./graphs/a_'$fw'_wb.eps'
		fn_out_gif='./graphs/a_'$fw'.gif'	

		gnuplot -e "fn_out_gif='$fn_out_gif'" -e "fn_out_png='$fn_out_png'" -e "fn_out_eps_wb='$fn_out_eps_wb'" -e "fn_in='$fn_in'" -e "num='$num'" -e "y_label='$y_label'" many_graph_T
	fi
	if [ "$mode" == "S" ]
	then
		cat $home_path'/calib_res' | grep 'fw_'$fw > tmp2
		paste './res/'$fw tmp2 > tmp3
		awk '{print $1, ($2*$6 + $7), sqrt(($2*$8)*($2*$8) + ($6*$3)*($6*$3) + $9*$9)}' tmp3 > './res/'$fw

		y_label="S, Ja"
		fn_out_eps_wb='./graphs/'$fw'_wb.eps'
		fn_out_gif='./graphs/'$fw'.gif'	

		gnuplot -e "fn_out_gif='$fn_out_gif'" -e "fn_out_png='$fn_out_png'" -e "fn_out_eps_wb='$fn_out_eps_wb'" -e "fn_in='$fn_in'" -e "num='$num'" -e "y_label='$y_label'" many_graph_S
	fi
done

rm tmp2
rm tmp3
