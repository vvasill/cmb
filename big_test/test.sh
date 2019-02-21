#!/bin/bash

fr="030"
fw="0"
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077" #arcdeg
home_path="/media/vasiliy/7236A2E636A2AB15/vasiliy/cmb_debug"
factor_line="1.5 2.0 3.0 4.0 5.0 8.0 12.0"
delta=20.0
i='1'
BW_str=( $beamwidth )
sxt_config='./sxt_config/config'
sigma=1.0
area_num='area_'$i'.0'
echo $i'_'$fr'_'$fw

################## 0 ###########################################################

M030=$home_path'/maps/m_030_R2.01.fts'
M044=$home_path'/maps/m_044_R2.01.fts'
M070=$home_path'/maps/m_070_R2.01.fts'
M100=$home_path'/maps/m_100_R2.02.fts'
M143=$home_path'/maps/m_143_R2.02.fts'
M217=$home_path'/maps/m_217_R2.02.fts'
M353=$home_path'/maps/m_353_R2.02.fts'
M545=$home_path'/maps/m_545_R2.02.fts'
M857=$home_path'/maps/m_857_R2.02.fts'

#loop_on_freq
count=0
BW=${BW_str[$count]}
fw_d=$( echo $fw/60.0 | bc -l )
if (( $( echo $BW '>' $fw_d | bc -l ) ))
then
	delta_small=$( echo $BW*1.5 | bc -l )
else
	delta_small=$( echo $fw_d*1.5 | bc -l )
fi

echo 'delta_small: '$delta_small

#set path to current map
case $fw in
0)
	MAP='M'$fr;;
*)
	MAP_0=$home_path'/maps/smoothed_maps/'$fr'_'$fw'_smooth_map.fts'
	MAP='MAP_0';;
esac

################## 1 ###########################################################

cat Planck_list | grep $fr'_' | grep $area_num | awk -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s %s %s\n", $1, num, fr, fw, ($8*15.0), $9}' > decimal_coord_list
#decimal_coord_list: name, ra, dec
	
#cut big area
cat big_areas_list_equ |awk -v fr=$fr -v fw=$fw -v d=$delta '{printf "q%s_%s_%s_%s %sd %sd\n", $1, fr, fw, d, $2, $3}' > fig_coord_list$$		
#mapcut ${!MAP} -fzq1 fig_coord_list$$ -zd $delta'd'
#f2fig ${!MAP} -fzq1 fig_coord_list$$ -zd $delta'd' -Cs nat

> m0_test
> big_area_sources

big_map='q'$i'_'$fr'_'$fw'_'$delta'.fts'

#sextractor $big_map -c $sxt_config -DETECT_THRESH $sigma -ANALYSIS_THRESH $sigma > /dev/null 2>&1
sed -i -e 's/+//g' sxt_output 
awk 'BEGIN{CONVFMT="%.9f"}{for(i=1; i<=NF; i++)if($i~/^[0-9]+([eE][+-][0-9]+)?/)$i+=0;}1' sxt_output > big_area_sources
	
cat decimal_coord_list | while read coord_line
do
	p_str=( $coord_line )	
	source_name=${p_str[0]}
	ra=${p_str[1]}
	dec=${p_str[2]}
				
	ra_l=$( echo $ra - $delta_small*0.5 | bc -l )
	ra_r=$( echo $ra + $delta_small*0.5 | bc -l )
	dec_l=$( echo $dec - $delta_small*0.5 | bc -l )
	dec_r=$( echo $dec + $delta_small*0.5 | bc -l )

	awk -v ra_l=$ra_l -v ra_r=$ra_r -v dec_l=$dec_l -v dec_r=$dec_r -v source_name=$source_name '{if ($5 > ra_l && $5 < ra_r && $6 > dec_l && $6 < dec_r) {printf "%s %s %s %s %s %s\n", source_name, $2, $3, $4, $5, $6}}' big_area_sources >> m0_test
	echo '***' >> m0_test
done

################## 2 ###########################################################

for factor in $factor_line
do 
	cat Planck_list | grep $fr'_' | grep $area_num | awk -v factor=$factor -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s_%s %s %s\n", factor, $1, num, fr, fw, ($8*15.0), $9}' > $factor'_decimal_coord_list'
	#decimal_coord_list: name, ra, dec

	#cut small areas
	cat Planck_list | grep $fr'_' | grep $area_num | awk -v factor=$factor -v num=$i -v fr=$fr -v fw=$fw '{printf "%s_%s_%s_%s_%s %s %s\n", factor, $1, num, fr, fw, $3, $4}' > fig_coord_list$$
	#fig_coord_list: name, ra_h, dec_h

	delta_test=$( echo $delta_small/1.5*$factor | bc -l )
	echo $delta_test
		
	cat fig_coord_list$$ | while read coord_line
	do	
		echo $coord_line > coord_line$$
		echo $coord_line
		f2fig  ${!MAP} -fzq1 coord_line$$ -zd $delta_test'd' -Cs nat #> /dev/null 2>&1
		mapcut ${!MAP} -fzq1 coord_line$$ -zd $delta_test'd' > /dev/null 2>&1
	done

	outfile='m'$factor'_test'
	> $outfile

	cat $factor'_decimal_coord_list' | while read line
	do
		echo $line > coord_line$$
		str=( $line )
		source_name=${str[0]}
		fits_name=${str[0]}'.fts'
		ra=${str[1]}
		dec=${str[2]}		

		ra_l=$( echo $ra - $delta_small*0.5 | bc -l )
		ra_r=$( echo $ra + $delta_small*0.5 | bc -l )
		dec_l=$( echo $dec - $delta_small*0.5 | bc -l )
		dec_r=$( echo $dec + $delta_small*0.5 | bc -l )	
					
		sextractor $fits_name -c $sxt_config -DETECT_THRESH $sigma -ANALYSIS_THRESH $sigma > /dev/null 2>&1
		awk 'BEGIN{CONVFMT="%.9f"}{for(i=1; i<=NF; i++)if($i~/^[0-9]+([eE][+-][0-9]+)?/)$i+=0;}1' sxt_output > sxt_tmp
		sed -i -e 's/+//g' sxt_tmp
		awk -v ra_l=$ra_l -v ra_r=$ra_r -v dec_l=$dec_l -v dec_r=$dec_r -v source_name=$source_name '{if ($5 > ra_l && $5 < ra_r && $6 > dec_l && $6 < dec_r) {printf "%s %s %s %s %s %s\n", source_name, $2, $3, $4, $5, $6}}' sxt_tmp >> $outfile
		echo '***' >> $outfile
	done
done

################## 3 ###########################################################
									
#empty_trash	
if [ -f coord_line$$ ]; then rm coord_line$$; fi
if [ -f fig_coord_list$$ ]; then rm fig_coord_list$$; fi

shutdown
