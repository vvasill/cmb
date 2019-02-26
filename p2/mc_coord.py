import sys, glob, os
from math import *
import numpy as np

ra = float(sys.argv[1])/15.0
dec = float(sys.argv[2])

ra_h = int(ra)
ra_m = abs(int((ra - int(ra))*60))
ra_s = abs(((ra - int(ra))*60 - int((ra - int(ra))*60))*60)
dec_d = int(dec)
dec_m = abs(int((dec - int(dec))*60))
dec_s = abs(((dec - int(dec))*60 - int((dec - int(dec))*60))*60)

print str(ra_h) + ":" + str(ra_m) + ":" + str(ra_s)
print str(dec_d) + ":" + str(dec_m) + ":" + str(dec_s)
