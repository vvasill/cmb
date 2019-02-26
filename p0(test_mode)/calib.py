import sys, glob, os
from math import *
import numpy as np

x = np.genfromtxt(sys.argv[1], usecols=(1))
y = np.genfromtxt(sys.argv[1], usecols=(3))

A = np.vstack([x, np.ones(len(x))]).T
a, b = np.linalg.lstsq(A, y)[0]

print (a)
print (b)
