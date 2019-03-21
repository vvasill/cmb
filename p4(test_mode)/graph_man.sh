#!/bin/bash

mode="S"
fw=60
#rlim=0.00045
#llim=0.0001
#step=0.0001

rlim=1.4
llim=0
step=0.2

if [ "$mode" == "T" ]
then
	fn_in='./res/T_'$fw
	fn_out_eps_wb='./graphs/T_'$fw'_wb.eps'
	y_label='{/Helvetica-Italic T}, K'

	gnuplot -e "fn_out_eps_wb='$fn_out_eps_wb'" -e "fn_in='$fn_in'" -e "y_label='$y_label'" -e "rlim='$rlim'" -e "llim='$llim'" -e "step='$step'" many_graph_man
fi

if [ "$mode" == "S" ]
then
	fn_in='./res/S_'$fw
	fn_out_eps_wb='./graphs/S_'$fw'_wb.eps'
	y_label='{/Helvetica-Italic S}, Ja'

	gnuplot -e "fn_out_eps_wb='$fn_out_eps_wb'" -e "fn_in='$fn_in'" -e "y_label='$y_label'" -e "rlim='$rlim'" -e "llim='$llim'" -e "step='$step'" many_graph_man
fi

#cp $fn_out_eps_wb ../text/images/
#cd ../text
#pdflatex text.tex

