#!/bin/bash

MAP=$1
coord_list='../'$2
small_delta=$3
coord_line='../temp/coord_line$$'

cd ./small_areas
cat $coord_list | while read line
do
	echo $line > $coord_line
	f2fig  $MAP -fzq1 $coord_line -zd $small_delta'd' -Cs nat > /dev/null 2>&1
	mapcut $MAP -fzq1 $coord_line -zd $small_delta'd' > /dev/null 2>&1
done

