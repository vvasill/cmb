import sys, glob, os
from math import *
import numpy as np
from astropy.io import fits
from astropy import wcs
import scipy
import scipy.ndimage as ndimage
import scipy.ndimage.filters as filters
import matplotlib.pyplot as plt

hdulist = fits.open(sys.argv[1], ignore_missing_end=True)
data = np.array(hdulist[0].data, dtype = np.float32)

neighborhood_size = 100
threshold = 1500

data_max = filters.maximum_filter(data, neighborhood_size)
maxima = (data == data_max)

#diff = ((data_max - data_min) > threshold) 
#smaxima[diff == 0] = 0

labeled, num_objects = ndimage.label(maxima)
slices = ndimage.find_objects(labeled)
x, y = [], []
for dy,dx in slices:
    x_center = (dx.start + dx.stop - 1)/2
    x.append(x_center)
    y_center = (dy.start + dy.stop - 1)/2    
    y.append(y_center)

print x
print y


plt.imshow(data)
plt.savefig('/tmp/data.png', bbox_inches = 'tight')

plt.autoscale(False)
plt.plot(x,y, 'ro')
plt.savefig('/tmp/result.png', bbox_inches = 'tight')
plt.show()
