#!/bin/bash

### This script try to calibrate signal, which we can extract from PLANCK-maps, from integral temperature to flux --- old version, August 2018###

### set parameters of maps ###
#map frequences
FREQ="030 044 070 100 143 217" #GHz
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077" #arcdeg
#smoothing angle
FWHM="0 5 35 60" #arcmin

### set project directory ###
#home_path="/users/vasily/data"
#home_path="/D/vasiliy/cmb"
home_path="/media/vasiliy/60Gb/cmb"

### extract sources from PLANCK maps in set areas###
echo preparing...
#./Planck_list_prepare.sh "$home_path"
echo cutting and sextracting...
#./calib_prepare.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path"

### calibrate usung leastsquares ###
echo calibrating...
./calib.sh "$FREQ" "$FWHM" "$home_path"
./corr.sh "$FREQ" "$FWHM"

#echo latexing...
#cp ./graphs/*.eps ../text/images/
#cd ../text
#pdflatex text.tex
