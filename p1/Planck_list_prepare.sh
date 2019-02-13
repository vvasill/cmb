#!/bin/bash

### prepare PLANCK catalogue for work ###

home_path=$1
delta=20.0

#getting some fields from Planck.cats
cat $home_path'/Planck.cats' | grep -v '^#' | awk 'function sgn(x){ if (x>0) return 1; else if (x<0) return -1 ; else return 0} BEGIN{num=1}{printf "%s %s %s:%s:%s %s:%s:%s %s %s %s %s %s no_area\n", num, $2, $3, $4, $5, $7, $8, $9, $11/1000, $12, $13, ($3 + $4/60 + $5/3600), ($7 + sgn($7)*$8/60 + sgn($7)*$9/3600); num+=1}' > Planck_list

#getting list without comments in equ coord
cat $home_path'/big_areas_list' | grep -v '^#' > actual_list
python Planck_list_prepare.py actual_list $delta
python list_conv.py actual_list 1
python list_conv.py actual_list 2
if [ -f actual_list ]; then rm actual_list; fi

#getting Planck_list with areas marks
cat big_areas_list_equ_bound | grep -v '^#' | while read line
do    
    str=( $line )
	num=${str[0]}
	ra_l=${str[1]}
	ra_r=${str[2]}
	dec_l=${str[3]}
	dec_r=${str[4]}
	area_name='area_'$num

	awk -v ra_l=$ra_l -v ra_r=$ra_r -v dec_l=$dec_l -v dec_r=$dec_r -v area_name=$area_name '{if ($8 > ra_l && $8 < ra_r && $9 > dec_l && $9 < dec_r) {printf "%s %s %s %s %s %s %s %s %s %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, area_name} else {printf "%s %s %s %s %s %s %s %s %s %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}}' Planck_list > tmp && mv tmp Planck_list

done
