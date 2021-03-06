#!/bin/bash

aM030=/home/vo/Planck/DR2/a_030_R2.01.fts
aM044=/home/vo/Planck/DR2/a_044_R2.01.fts
aM070=/home/vo/Planck/DR2/a_070_R2.01.fts
aM100=/home/vo/Planck/DR2/a_100_R2.02.fts
aM143=/home/vo/Planck/DR2/a_143_R2.02.fts
aM217=/home/vo/Planck/DR2/a_217_R2.02.fts
aM353=/home/vo/Planck/DR2/a_353_R2.02.fts
aM545=/home/vo/Planck/DR2/a_545_R2.02.fts
aM857=/home/vo/Planck/DR2/a_857_R2.02.fts

LFREC="030 044 070 100 143 217 353 545 857"
FWHM="5 10 15 30 45 60 120 300 600"
LFREC="030 044 100 143 217"

cd /users/vasily/data/maps/smoothed_maps

#loop_on_freq
for fr in $LFREC
do
	MAP='aM'$fr
	
	for fw in $FWHM
	do
		echo $fr' '$fw
	
		lmax=$(echo 360.0*60.0/$fw | bc -l)
		nx=$(python -c "print 2*$lmax + 1")
		np=$(python -c "print 2*(2*$lmax + 1)")
		
		#convolving and map generation	
		rsalm ${!MAP} -fw $fw -o $fr'_'$fw'_alm.fts'
 		cl2map -falm $fr'_'$fw'_alm.fts' -o $fr'_'$fw'_smooth_map.fts' -lmax $lmax -nx $nx -np $np
		f2fig $fr'_'$fw'_smooth_map.fts' -o $fr'_'$fw'_smooth_map.gif'
	done

	echo "FREQ: $fr - done"
done

#empty_trash
