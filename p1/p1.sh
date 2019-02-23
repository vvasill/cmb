#!/bin/bash

### This script try to calibrate signal, which we can extract from PLANCK-maps, from integral temperature to flux ###

### set parameters of maps ###
#map frequences
FREQ="030 044 070 100 143 217" #GHz
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077" #arcdeg
#smoothing angle
FWHM="0 5 35 60" #arcmin

FREQ="030"
FWHM="5"

### set project directory ###
#home_path="/users/vasily/data"
#home_path="/D/vasiliy/cmb"
#home_path="/media/vasiliy/60Gb/cmb"
home_path="/media/vasiliy/7236A2E636A2AB15/vasiliy/cmb_debug"

### mark in what area source is situated ###
echo preparing...
#./Planck_list_prepare.sh "$home_path"

### extract sources from PLANCK maps in set areas ###
if [ "$1" == "a" ] 
then
	echo cutting and sextracting...
	./calib_prepare.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path" auto
else
	echo cutting and sextracting...
	./calib_prepare.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path" control
fi

### calibrate usung leastsquares ###
if [ "$1" == "a" ] 
then
	echo calibration...
	./calibration.sh "$FREQ" "$FWHM" "$home_path" auto
else
	echo calibrating...
	./calibration.sh "$FREQ" "$FWHM" "$home_path" control
fi

#./corr.sh "$FREQ" "$FWHM"

#echo latexing...
#cp ./graphs/*.eps ../text/images/
#cd ../text
#pdflatex text.tex
