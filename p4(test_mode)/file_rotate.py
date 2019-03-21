import sys, glob, os
import numpy as np

file_in = np.loadtxt(sys.argv[1])
file_out = np.transpose(file_in)
file_in_err = np.loadtxt(sys.argv[4])
file_out_err = np.transpose(file_in_err)
av = np.zeros((file_out.shape[0], 2))
av_err = np.zeros((file_out_err.shape[0], 2))

flux = np.delete(file_out, 0, axis=1)
flux_err = np.delete(file_out_err, 0, axis=1)

av[:,1] = np.mean(flux, axis=1)

for i in range(0, av.shape[0]):
	av[i,0] = file_out[i,0]
	av_err[i,0] = file_out_err[i,0]
	for j in range(1, file_out_err.shape[1]):
		av_err[i,1] += (file_out_err[i,j])**2
	av_err[i,1] = np.sqrt(av_err[i,1])/(file_out_err.shape[1]-1)

std_err = np.std(flux, axis=1)/np.sqrt(file_out.shape[1]-2)
av_err[:,1] = np.sqrt(av_err[:,1]**2 + std_err[:]**2)

np.savetxt(sys.argv[2], file_out, fmt='%s')
np.savetxt(sys.argv[3], av, fmt='%s')
np.savetxt(sys.argv[5], file_out_err, fmt='%s')
np.savetxt(sys.argv[6], av_err, fmt='%s')
