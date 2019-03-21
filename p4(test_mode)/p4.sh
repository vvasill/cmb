#!/bin/bash

### test variety of p2 script with more accurate extracting of sources ###
### This script plot spectrum of spots, detected on SMICA map ###

### set parameters of maps ###
#map frequences
FREQ="030 044 070 100 143 217" #GHz
beamwidth="0.54 0.45 0.22 0.16 0.12 0.083 0.082 0.080 0.077" #arcdeg
#smoothing angle
FWHM="0 5 35 60"
#threshold for SExtractor
sigma="1.0"

FREQ="030"
FWHM="0"

### set project directory ###
#home_path="/D/vasiliy/cmb"
home_path="/home/cmb_debug"

if [ ! -d ./temp ]; then mkdir ./temp; fi
if [ ! -d ./big_areas ]; then mkdir ./big_areas; fi
if [ ! -d ./small_areas ]; then mkdir ./small_areas; fi
if [ ! -d ./def_coords ]; then mkdir ./def_coords; fi
if [ ! -d ./corr ]; then mkdir ./corr; fi
if [ ! -d ./match ]; then mkdir ./match; fi
if [ ! -d ./res ]; then mkdir ./res; fi	
if [ ! -d ./graphs ]; then mkdir ./graphs; fi	

echo list of sources and big areas list preparing...
#./Planck_list_prepare.sh "$home_path"

### get coords of spots on SMICA maps ###
echo def coords from SMICA...
#./def_coords.sh "$FWHM" "$home_path" "$sigma"

echo small areas cutting...
./small_areas_cut.sh "$FREQ" "$FWHM" "$beamwidth" "$home_path"

### extract sources from freq-map ###
echo extracting and calibrating
#./s_extracting.sh "$FREQ" "$FWHM" "$sigma"

#./calibrating.sh "$FREQ" "$FWHM" "$home_path" S "$sigma"

#./joining.sh "$FWHM" S

#./rotate_graph.sh "$FWHM" S "$home_path"

if [ -d ./temp ]; then rm -r ./temp; fi
