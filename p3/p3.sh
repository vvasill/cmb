#!/bin/bash

### This script try to calibrate signal, which we can extract from PLANCK-maps, from integral temperature to flux ###

### set parameters of maps ###
#map frequences
FREQ="030 044 070 100 143 217" #GHz
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077" #arcdeg
#smoothing angle
FWHM="0 5 35 60" #arcmin
FWHM="0" #arcmin

### set project directory ###
#home_path="/users/vasily/data"
#home_path="/D/vasiliy/cmb"
home_path="/media/vasiliy/60Gb/cmb_debug"

### mark in what area source is situated ###
echo "preparing..."
#./Planck_list_prepare.sh "$home_path"

### cut big areas from smoothed maps ###
echo "cutting..."
#./big_areas_cut.sh "$FREQ" "$FWHM" "$home_path"

### extract sources from freq-map ###
echo "source extracting..."
#./sextracting.sh "$FREQ" "$FWHM" "$home_path"

echo "matching..."
#./matching.sh "$FREQ" "$FWHM" "$beamwidth"

### calibrate using leastsquares ###
echo "calibrating..."
./calib.sh "$FREQ" "$FWHM" "$home_path"

### find correlations (not for calibration, see p2) ### 
echo "finding correlations..."
#./corr.sh "$FREQ" "$FWHM"

#echo "latexing..."
#cp ./graphs/*.eps ../text/images/
#cd ../text
#pdflatex text.tex
