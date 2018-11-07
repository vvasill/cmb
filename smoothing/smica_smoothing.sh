#!/bin/bash

MAP=/home/vo/Planck/DR2/a_smica2.01.fts

FWHM="35"

cd /users/vasily/data/maps/smoothed_maps

for fw in $FWHM
do
	echo $fw
	
	lmax=$(echo 360.0*60.0/$fw | bc -l)
	nx=$(python -c "print 2*$lmax + 1")
	np=$(python -c "print 2*(2*$lmax + 1)")
		
	#convolving and map generation	
	rsalm $MAP -fw $fw -o 'smica_'$fw'_alm.fts'
 	cl2map -falm 'smica_'$fw'_alm.fts' -o 'smica_'$fw'_smooth_map.fts' -lmax $lmax -nx $nx -np $np
	f2fig $'smica_'$fw'_smooth_map.fts' -o 'smica_'$fw'_smooth_map.gif'
done

#empty_trash
