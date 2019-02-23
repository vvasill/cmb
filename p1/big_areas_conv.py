import sys, glob, os
from math import *
import numpy as np

from coord_conv import equ2gal
from coord_conv import gal2equ

areas_in = np.loadtxt(sys.argv[1])
delta = float(sys.argv[2])*0.5

areas_out = np.zeros((areas_in.shape[0], areas_in.shape[1]+1))

for i in range(0, areas_in.shape[0]):
	areas_out[i,0] = areas_in[i,0]
	ra = gal2equ(areas_in[i,2], areas_in[i,1])[0]
	dec = gal2equ(areas_in[i,2], areas_in[i,1])[1]
	areas_out[i,1] = ra - delta
	areas_out[i,2] = ra + delta
	areas_out[i,3] = dec - delta
	areas_out[i,4] = dec + delta

np.savetxt('big_areas_list_equ', areas_out, fmt="%s")
