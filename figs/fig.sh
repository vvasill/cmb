#!/bin/bash

M030=/home/vo/Planck/DR2/m_030_R2.01.fts
M217=/home/vo/Planck/DR2/m_217_R2.02.fts

rescale=40
fr=030
cat Planck_list | grep $fr'_' | awk -v rescale=$rescale '{printf "%s %s 0 %s 0\n", $3, $4, $6*rescale}' > full_fig_Planck_list 
#f2fig $M030 -C -0.0004,0.0004 -gr g -d1 10.0d -d2 10.0d -o areas_030.eps -pf coords -feq -fs full_fig_Planck_list -xs 3200 -ys 1600 -notitle
#f2fig $M030 -C -0.0004,0.0004 -gr g -d1 10.0d -d2 10.0d -o areas_030_wb.gif -pf coords_wb -feq -fs full_fig_Planck_list -xs 3200 -ys 1600 -c 0 -notitle
f2fig $M030 -C -0.0003,0.0003 -o areas_030.gif -pf coords -xs 3200 -ys 1600 -notitle -b
f2fig $M030 -C -0.0003,0.0003 -o areas_030_wb.gif -pf coords_wb -xs 3200 -ys 1600 -c 0 -notitle -b

fr=217
cat Planck_list | grep $fr'_' | awk -v rescale=$rescale '{printf "%s %s 0 %s 0\n", $3, $4, $6*rescale}' > full_fig_Planck_list 
#f2fig $M217 -C -0.0004,0.0004 -gr g -o areas_217.gif -pf coords -feq -fs full_fig_Planck_list -xs 3200 -ys 1600 -notitle
#f2fig $M217 -C -0.0004,0.0004 -gr g -o areas_217_wb.gif -pf coords_wb -feq -fs full_fig_Planck_list -xs 3200 -ys 1600 -c 0 -notitle
f2fig $M217 -C -0.0003,0.0003 -o areas_217.gif -pf coords -xs 3200 -ys 1600 -notitle -b
f2fig $M217 -C -0.0003,0.0003 -o areas_217_wb.gif -pf coords_wb -xs 3200 -ys 1600 -c 0 -notitle -b
