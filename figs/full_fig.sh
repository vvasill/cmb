#!/bin/bash

M030=/home/vo/Planck/DR2/m_030_R2.01.fts
M044=/home/vo/Planck/DR2/m_044_R2.01.fts
M070=/home/vo/Planck/DR2/m_070_R2.01.fts
M100=/home/vo/Planck/DR2/m_100_R2.02.fts
M143=/home/vo/Planck/DR2/m_143_R2.02.fts
M217=/home/vo/Planck/DR2/m_217_R2.02.fts
M353=/home/vo/Planck/DR2/m_353_R2.02.fts
M545=/home/vo/Planck/DR2/m_545_R2.02.fts
M857=/home/vo/Planck/DR2/m_857_R2.02.fts
	
path='M'$1
echo $path

#drawing maps with  
#f2fig ${!path} -C $2,$3 -o $1'.gif' -gr g -cats Planck.cats

#cat test_test | awk '{printf "%s  %s 0 %s 0\n", system("python coord_conv.py equ2gal b " $8 " " $9), system("python coord_conv.py equ2gal l " $8 " " $9), $6}' > full_fig_Planck_list 

fr=143
rescale=40
size=1600
cat Planck_list | grep $fr'_' | awk -v rescale=$rescale '{printf "%s %s 0 %s 0\n", $3, $4, $6*rescale}' > full_fig_Planck_list 

f2fig $M030 -C -0.0004,0.0004 -o './full_fig/big_area_1.gif' -feq -fs full_fig_Planck_list -xs 3200 -ys 1600 -gr g -d1 10.0d -d2 10.0d

if [ -f full_fig_Planck_list  ]; then rm full_fig_Planck_list; fi
