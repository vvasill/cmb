#!/bin/bash

FWHM=$1
mode=$2

echo "0 30 30 40 40 70 70 100 100 143 143 217 217" > freq_line

if [ "$mode" == "T" ]
then
	infile='./match/T_calib_outfile'
	outfile='./res/T_res_'
	out='./res/T_flux_'
fi
if [ "$mode" == "S" ]
then
	infile='./match/S_calib_outfile'
	outfile='./res/S_res_'
	out='./res/S_flux_'
fi

for fw in $FWHM
do
	> $outfile$fw
	
	#joining
	./join_all.sh $infile'_217_'$fw $infile'_143_'$fw $infile'_100_'$fw $infile'_070_'$fw $infile'_044_'$fw $infile'_030_'$fw > $outfile$fw

	#adding line with freqs
	cat freq_line $outfile$fw > tmp && mv tmp $outfile$fw
	
	#deleting first column and extracting columns for fluxes
	awk '{$1 = ""; print $i}' $outfile$fw > tmp 
	awk '{for (i=1; i<=NF; i++) if (i % 2) printf "%s", $i (i == NF || i == (NF-1)?"\n":" ")}' tmp > $out$fw

	#deleting first column and extracting columns for fluxes
	awk '{$1 = ""; $2 = ""; print $i}' $outfile$fw > tmp
	awk '{for (i=1; i<=NF; i++) if (i % 2) printf "%s", $i (i == NF || i == (NF-1)?"\n":" ")}' tmp > $out'err_'$fw

done

#empty_trash
if [ -f freq_line ]; then rm freq_line; fi	
if [ -f tmp ]; then rm tmp; fi
for file in $outfile*
do
	if [ -f $file ]; then rm $file; fi
done		
