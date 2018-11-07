#!/bin/bash

# > /dev/null 2>&1

FREQ="030 044 070 100 143 217"
FWHM="0 5 35 60"
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077"

home_path="/D/vasiliy/cmb"

echo list of sources and big areas list preparing...
#./Planck_list_prepare.sh "$home_path"
echo def coords from SMICA...
#./def_coords.sh "$FWHM" "$home_path"
echo cutting...
#./big_areas_cut.sh "$FREQ" "$FWHM" "$home_path"
if [ "$1" == "a" ] 
then
	echo "alternartive source extracting..."
#	./a_extracting.sh "$FREQ" "$FWHM" "$beamwidth"
else
	echo sextracting...
#	./sextracting.sh "$FREQ" "$FWHM"
fi
#./with_corr.sh "$FREQ" "$FWHM" "$beamwidth" no "$home_path"
if [ "$1" == "a" ] 
then
	echo matching...
#	./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" max
else
	echo matching...
#	./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" av
fi
if [ "$1" == "a" ] 
then
	echo calibrating...
	./calibrating.sh "$FREQ" "$FWHM" "$home_path" no
else
	echo calibrating...
	./calibrating.sh "$FREQ" "$FWHM" "$home_path" no
fi
echo joining...
./joining.sh "$FWHM"
echo rotating and graphing...
if [ "$1" == "a" ] 
then
	./rotate.sh "$FWHM" T "$home_path"
else
	./rotate.sh "$FWHM" S "$home_path"
fi

echo latexing...
cp ./graphs/*.eps ../text/images/
cd ../text
pdflatex text.tex
