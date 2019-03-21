import sys, glob, os
from math import *
import numpy as np

from coord_conv import equ2gal
from coord_conv import gal2equ

if (sys.argv[2] == "1"):
	areas_in = np.loadtxt(sys.argv[1])
	areas_out = np.zeros((areas_in.shape[0], areas_in.shape[1]+3))

	for i in range(0, areas_in.shape[0]):
		areas_out[i,0] = areas_in[i,0]
		ra = (gal2equ(areas_in[i,2], areas_in[i,1])[0])/15.0
		dec = gal2equ(areas_in[i,2], areas_in[i,1])[1]
		areas_out[i,1] = int(ra)
		areas_out[i,2] = abs(int((ra - int(ra))*60))
		areas_out[i,3] = abs(((ra - int(ra))*60 - int((ra - int(ra))*60))*60)
		areas_out[i,4] = int(dec)
		areas_out[i,5] = abs(int((dec - int(dec))*60))
		areas_out[i,6] = abs(((dec - int(dec))*60 - int((dec - int(dec))*60))*60)
	
	np.savetxt('big_areas_list_equ', areas_out, fmt='%d %d:%d:%s %d:%d:%s')

if (sys.argv[2] == "2"):
	areas_in = np.loadtxt(sys.argv[1])
	areas_out = np.zeros((areas_in.shape[0], areas_in.shape[1]-1))	

	for i in range(0, areas_in.shape[0]):
		areas_out[i,0] = areas_in[i,0]
		ra = (gal2equ(areas_in[i,2], areas_in[i,1])[0])/15.0
		dec = gal2equ(areas_in[i,2], areas_in[i,1])[1]
		areas_out[i,1] = ra
		areas_out[i,2] = dec
	
	np.savetxt('big_areas_list_equ_norm', areas_out, fmt='%d %s %s')
