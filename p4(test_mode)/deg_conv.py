import sys, glob, os
from math import *
import numpy as np

areas_in = np.loadtxt(sys.argv[1])
areas_out = np.zeros((areas_in.shape[0], areas_in.shape[1]))

for i in range(0, areas_in.shape[0]):
	areas_out[i,0] = areas_in[i,0]
	ra = areas_in[i,1]/15.0
	dec = areas_in[i,2]
	areas_out[i,1] = int(ra)
	areas_out[i,2] = abs(int((ra - int(ra))*60))
	areas_out[i,3] = abs(((ra - int(ra))*60 - int((ra - int(ra))*60))*60)
	areas_out[i,4] = int(dec)
	areas_out[i,5] = abs(int((dec - int(dec))*60))
	areas_out[i,6] = abs(((dec - int(dec))*60 - int((dec - int(dec))*60))*60)
	
print(areas_out, fmt='%d %d:%d:%s %d:%d:%s')
