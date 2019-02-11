#!/bin/bash

FREQ="030 044 070 100 143 217"
FWHM="0 5 35 60"
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077"

#home_path="/D/vasiliy/cmb"
home_path="/media/vasiliy/60Gb/cmb"

echo list of sources and big areas list preparing...
#./Planck_list_prepare.sh "$home_path"

### get coords of spots on SMICA maps ###
echo def coords from SMICA...
#./def_coords.sh "$FWHM" "$home_path"

### cut small areas from smoothed maps ###
echo cutting...
#./big_areas_cut.sh "$FREQ" "$FWHM" "$home_path"

if [ "$1" == "a" ] 
then
	echo "alternartive (max amplitude) source extracting..."
#	./a_extracting.sh "$FREQ" "$FWHM" "$beamwidth"
else
	echo sextracting...
#	./sextracting.sh "$FREQ" "$FWHM"
fi
#./with_corr.sh "$FREQ" "$FWHM" "$beamwidth" no "$home_path"

### match spots and sources ###
if [ "$1" == "a" ] 
then
	echo matching...
#	./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" T
else
	echo matching...
	./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" S
fi

if [ "$1" == "a" ] 
then
	echo calibrating...
	./calibrating.sh "$FREQ" "$FWHM" "$home_path" T
else
	echo calibrating...
	./calibrating.sh "$FREQ" "$FWHM" "$home_path" S
fi

### joining ###
echo joining...
if [ "$1" == "a" ] 
then
	./joining.sh "$FWHM" T
else
	./joining.sh "$FWHM" S
fi

### rotating and graphing ###
echo rotating and graphing...
if [ "$1" == "a" ] 
then
	./rotate_graph.sh "$FWHM" T "$home_path"
else
	./rotate_graph.sh "$FWHM" S "$home_path"
fi

### graphing... ###
#./graph_man.sh

#echo latexing...
#cp ./graphs/*.eps ../text/images/
#cd ../text
#pdflatex text.tex
