#!/bin/bash

### This script plot spectrum of spots, detected on SMICA map ###

### set parameters of maps ###
#map frequences
FREQ="030 044 070 100 143 217" #GHz
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077" #arcdeg
#smoothing angle
FWHM="0 5 35 60"
#threshold for SExtractor
sigma_line="1.0 2.0 3.0"
sigma_line='1.0'

### set project directory ###
#home_path="/D/vasiliy/cmb"
home_path="/media/vasiliy/60Gb/cmb_debug"

echo list of sources and big areas list preparing...
#./Planck_list_prepare.sh "$home_path"

### get coords of spots on SMICA maps ###
echo def coords from SMICA...
#./def_coords.sh "$FWHM" "$home_path"

### cut small areas from smoothed maps ###
echo cutting...
#./big_areas_cut.sh "$FREQ" "$FWHM" "$home_path"

### find correlations between SMICA and freq-map ###
echo correlating...
#./with_corr.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path" no 0.001

for sigma in $sigma_line
do
	### extract sources from freq-map ###
	if [ "$1" == "a" ] 
	then
		echo "alternartive (max amplitude) source extracting..."
	#	./a_extracting.sh "$FREQ" "$FWHM" "$beamwidth"
	#	./extracting.sh "$FREQ" "$FWHM" T "$sigma"
	else
		echo "source extracting..."
	#	./extracting.sh "$FREQ" "$FWHM" S "$sigma"
	fi

	### match spots and sources ###
	if [ "$1" == "a" ] 
	then
		echo matching...
	#	./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" T "$sigma"
	else
		echo matching...
	#	./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" S "$sigma"
	fi

	if [ "$1" == "a" ] 
	then
		echo calibrating...
	#	./calibrating.sh "$FREQ" "$FWHM" "$home_path" T "$sigma"
	else
		echo calibrating...
	#	./calibrating.sh "$FREQ" "$FWHM" "$home_path" S "$sigma"
	fi

	### joining ###
	if [ "$1" == "a" ] 
	then
		echo joining...	
	#	./joining.sh "$FWHM" T
	else
		echo joining...
	#	./joining.sh "$FWHM" S
	fi

	### rotating and automatic graphing ###
	if [ "$1" == "a" ] 
	then
		echo rotating and graphing...
	#	./rotate_graph.sh "$FWHM" T "$home_path"
	else
		echo rotating and graphing...
	#	./rotate_graph.sh "$FWHM" S "$home_path"
	fi
done

### plot graphs with axes control ###
#./graph_man.sh

### create text ###
#echo latexing...
#cp ./graphs/*.eps ../text/images/
#cd ../text
#pdflatex text.tex
