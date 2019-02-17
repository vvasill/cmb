import sys, glob, os
from math import *
import numpy as np

def equ2gal(ra_deg, dec_deg):

	ra = radians(ra_deg)
	dec = radians(dec_deg) 
	
	# North galactic pole (J2000)
	pole_ra = radians(192.859508)
	pole_dec = radians(27.128336)
	posangle = radians(122.932-90.0)
    
	l = atan2( (sin(dec)*cos(pole_dec) - cos(dec)*sin(pole_dec)*cos(ra-pole_ra)), (cos(dec)*sin(ra-pole_ra)) ) + posangle
	b = asin( sin(dec)*sin(pole_dec) + cos(dec)*cos(pole_dec)*cos(ra-pole_ra) )
    
	return degrees(l), degrees(b)

def gal2equ(l_deg, b_deg):

	l = radians(l_deg)
	b = radians(b_deg) 
	
	# North galactic pole (J2000)
	pole_ra = radians(192.859508)
	pole_dec = radians(27.128336)
	posangle = radians(122.932-90.0)
    
 	ra = atan2( (cos(b)*cos(l-posangle)), (sin(b)*cos(pole_dec) - cos(b)*sin(pole_dec)*sin(l-posangle)) ) + pole_ra
	dec = asin( cos(b)*cos(pole_dec)*sin(l-posangle) + sin(b)*sin(pole_dec) )
    
	return degrees(ra), degrees(dec)

