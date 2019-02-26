import sys, glob, os
from math import *
import numpy as np
from astropy.io import fits
from astropy import wcs
import scipy
import scipy.ndimage as ndimage
import scipy.ndimage.filters as filters
import matplotlib.pyplot as plt

name = sys.argv[6]

hdulist = fits.open(sys.argv[1], ignore_missing_end=True)
data = np.array(hdulist[0].data, dtype = np.float32)

delta = float(sys.argv[2])
neighborhood_size = int((float(sys.argv[3])/delta)*data.shape[0])
x_coord = float(sys.argv[4])
y_coord = float(sys.argv[5])
sigma = float(sys.argv[7])

threshold = sigma*np.std(data)

data_max = filters.maximum_filter(data, neighborhood_size)
maxima = (data == data_max)
diff = (data_max > threshold) 
maxima[diff == 0] = 0

x_, y_ = [], []
for i in range(0, data.shape[0]):
	for j in range(0, data.shape[1]):
		if (maxima[i,j] == True):
			y = (i - data.shape[0]/2)*1.0*delta/data.shape[0] + y_coord
			x = (j - data.shape[1]/2)*1.0*delta/data.shape[1]/15.0 + x_coord
			print name, data_max[i,j], "0.0", x*15.0, y
