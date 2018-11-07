#!/bin/bash

fw=5
rlim=0.0004
llim=0.00015
step=0.00005

fn_in='./res/'$fw
fn_out_eps_wb='./graphs/a_'$fw'_wb.eps'

gnuplot -e "fn_out_png='$fn_out_png'" -e "fn_out_eps_wb='$fn_out_eps_wb'" -e "fn_in='$fn_in'" -e "num='$num'" -e "y_label='$y_label'" -e "rlim='$rlim'" -e "llim='$llim'" -e "step='$step'" many_graph_man

cp $fn_out_eps_wb ../text/images/
cd ../text
pdflatex text.tex

