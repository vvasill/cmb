#!/bin/bash

FWHM=$1
echo "0 30 30 40 40 70 70 100 100 143 143 217 217" > freq_line
if [ ! -f ./res ]; then mkdir ./res; fi

for fw in $FWHM
do
	> './res/res_'$fw
	./join_all.sh ./match/calib_outfile_217_$fw ./match/calib_outfile_143_$fw ./match/calib_outfile_100_$fw ./match/calib_outfile_070_$fw ./match/calib_outfile_044_$fw ./match/calib_outfile_030_$fw > './res/res_'$fw

	cat freq_line './res/res_'$fw > tmp && mv tmp './res/res_'$fw
	
	#deleting first column
	awk '{$1 = ""; print $i}' './res/res_'$fw > tmp 
	awk '{for (i=1; i<=NF; i++) if (i % 2) printf "%s", $i (i == NF || i == (NF-1)?"\n":" ")}' tmp > './res/flux_'$fw
	num=$( cat './res/flux_'$fw | wc -l )
	echo $num
	awk '{$1 = ""; $2 = ""; print $i}' './res/res_'$fw > tmp
	awk '{for (i=1; i<=NF; i++) if (i % 2) printf "%s", $i (i == NF || i == (NF-1)?"\n":" ")}' tmp > './res/flux_err_'$fw
done

