#!/bin/bash

fr=70
fw=0
rlim=2.4
step=0.4

file_name='./out_data/calib_data_'$fr'_'$fw
file_name_extra='./out_data/extra_calib_data_'$fr'_'$fw
fn_out_gif='./graphs/'$fr'_'$fw'.gif'
fn_out_eps_wb='./graphs/'$fr'_'$fw'_wb.eps'

awk '{print $4}' $file_name > flux
awk '{print $2}' $file_name > temp
max_flux=$( awk -F= 'BEGIN { max = -inf } { if ($1 > max) { max = $1 } } END { print max }' flux )
max_temp=$( awk -F= 'BEGIN { max = -inf } { if ($1 > max) { max = $1 } } END { print max }' temp )
#cat $file_name | awk -v max_temp=$max_temp -v max_flux=$max_flux '{ if (! (($2 > 0.05*max_temp) && ($4 < 2.0)) ) { print $0 } }' > $file_name_extra
cat $file_name | awk -v max_temp=$max_temp -v max_flux=$max_flux '{ if (! (($2 > 0.1*max_temp) && ($4 < 0.1*max_flux)) ) { print $0 } }' > $file_name_extra
num=$( cat $file_name_extra | wc -l )
echo $fr $fw $num
		
a=$(echo $(python calib.py $file_name_extra) | cut -d' ' -f1)
b=$(echo $(python calib.py $file_name_extra) | cut -d' ' -f2)

echo $a
echo $b

gnuplot -e "fn_in='$file_name_extra'" -e "fn_out_gif='$fn_out_gif'" -e "fn_out_eps_wb='$fn_out_eps_wb'" -e "a='$a'" -e "b='$b'" -e "rlim='$rlim'" -e "step='$step'" graph_man

cp $fn_out_eps_wb ../text/images/

#corr_graph
fn_in='./out_data/calib_calib_data_'$fr'_'$fw
fn_out_gif='./graphs/corr_'$fr'_'$fw'.gif'	
fn_out_eps_wb='./graphs/corr_'$fr'_'$fw'_wb.eps'
#gnuplot -e "fn_in='$fn_in'" -e "fn_out_gif='$fn_out_gif'" -e "fn_out_eps_wb='$fn_out_eps_wb'" graph_corr

cp $fn_out_eps_wb ../text/images/
cd ../text
pdflatex text.tex

