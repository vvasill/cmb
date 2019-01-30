#!/bin/bash

#> /dev/null 2>&1

FREQ="030 044 070 100 143 217" #MHz
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077" #
FWHM="0 5 35 60"

#home_path="/users/vasily/data"
home_path="/D/vasiliy/cmb"

echo preparing...
#./Planck_list_prepare.sh "$home_path"

echo cutting and sextracting...
#./calib_prepare.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path"

echo calibrating...
./calib.sh "$FREQ" "$FWHM" "$home_path"
./corr.sh "$FREQ" "$FWHM"

echo latexing...
cp ./graphs/*.eps ../text/images/
cd ../text
pdflatex text.tex
