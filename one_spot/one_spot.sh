#!/bin/bash

#> /dev/null 2>&1

FREQ="030 044 070 100 143 217"
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077"
FWHM="0 5 35 60"

awk '{print $1, $2}' Planck_list > restricted_list

home_path="/users/vasily/data"

echo preparing...
#./preparing.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path"
echo extracting...
#./extracting.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path"
echo graphing...
./graphing.sh "$FREQ" "$home_path"
