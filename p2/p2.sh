#!/bin/bash

### This script plot spectrum of spots, detected on SMICA map ###

### set parameters of maps ###
#map frequences
FREQ="030 044 070 100 143 217" #GHz
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077" #arcdeg
#smoothing angles
FWHM="0 5 35 60"
#threshold for SExtractor
sigma_line="1.0"

### set project directory ###
#home_path="/D/vasiliy/cmb"
#home_path="/media/vasiliy/60Gb/cmb_debug"
home_path="/home/cmb_debug"

if [ ! -d ./temp ]; then mkdir ./temp; fi
if [ ! -d ./big_areas ]; then mkdir ./big_areas; fi
if [ ! -d ./def_coords ]; then mkdir ./def_coords; fi
if [ ! -d ./corr ]; then mkdir ./corr; fi
if [ ! -d ./match ]; then mkdir ./match; fi
if [ ! -d ./res ]; then mkdir ./res; fi	
if [ ! -d ./graphs ]; then mkdir ./graphs; fi	

echo list of sources and big areas list preparing...
./Planck_list_prepare.sh "$home_path"

### get coords of spots on SMICA maps ###
echo def coords from SMICA...
./def_coords.sh "$FWHM" "$home_path" "$sigma"

### cut big areas from smoothed maps ###
echo cutting...
./big_areas_cut.sh "$FREQ" "$FWHM" "$home_path"

### find correlations between SMICA and freq-map ###
echo correlating...
#./with_corr.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path" no 0.001

for sigma in $sigma_line
do
	### extract sources from freq-map ###
	if [ "$1" == "t" ] 
	then
		echo "amplitude source extracting..."
		./t_extracting.sh "$FREQ" "$FWHM" "$sigma" #sextractor extracting
	fi
	if [ "$1" == "test" ] 
	then
		echo "test (python) amplitude source extracting..."
		./a_extracting.sh "$FREQ" "$FWHM" "$beamwidth" "$sigma" #python extracting
	fi
	if [ "$1" == "s" ] 
	then
		echo "source extracting..."
		./s_extracting.sh "$FREQ" "$FWHM" "$sigma"
	fi

	### match spots and sources ###
	if [ "$1" == "t" ] 
	then
		echo matching...
		./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" T "$sigma"
	fi
	if [ "$1" == "test" ] 
	then
		echo matching...
		./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" A "$sigma"
	fi
	if [ "$1" == "s" ] 
	then
		echo matching...
		./spot_matching.sh "$FREQ" "$FWHM" "$beamwidth" S "$sigma"
	fi

	if [ "$1" == "t" ] 
	then
		echo calibrating...
		./calibrating.sh "$FREQ" "$FWHM" "$home_path" T "$sigma"
	fi
	if [ "$1" == "test" ] 
	then
		echo calibrating...
		./calibrating.sh "$FREQ" "$FWHM" "$home_path" A "$sigma"
	fi
	if [ "$1" == "s" ] 
	then
		echo calibrating...
		./calibrating.sh "$FREQ" "$FWHM" "$home_path" S "$sigma"
	fi

	### joining ###
	if [ "$1" == "t" ] 
	then
		echo joining...	
		./joining.sh "$FWHM" T
	fi
	if [ "$1" == "s" ] 
	then
		echo joining...
		./joining.sh "$FWHM" S
	fi

	### rotating and automatic graphing ###
	if [ "$1" == "t" ] 
	then
		echo rotating and graphing...
		./rotate_graph.sh "$FWHM" T "$home_path"
	fi
	if [ "$1" == "s" ] 
	then
		echo rotating and graphing...
		./rotate_graph.sh "$FWHM" S "$home_path"
	fi
done

### plot graphs with axes control ###
#./graph_man.sh
