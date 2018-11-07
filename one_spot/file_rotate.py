import sys, glob, os
from math import *
import numpy as np

file_in = np.loadtxt(sys.argv[1])
file_out = np.transpose(file_in)
file_in_err = np.loadtxt(sys.argv[3])
file_out_err = np.transpose(file_in_err)
	
np.savetxt(sys.argv[2], file_out, fmt='%s')
np.savetxt(sys.argv[4], file_out_err, fmt='%s')

