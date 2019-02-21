import numpy as np
import matplotlib.pyplot as plt

f_in = './res/2.txt'
f_out = './bg_plot_2.png'

x = np.genfromtxt(f_in, usecols=(0))
y = np.genfromtxt(f_in, usecols=(4))

plt.plot(x, y, 'ro')
plt.ticklabel_format(style='sci', axis='y', useMathText=True)
#plt.yticks(list(plt.yticks()[0]) + [209])
plt.xlabel(r'*bw $d_{cut}, arcdeg$')
plt.ylabel(r'Background, K')
plt.tight_layout()
#plt.axhline(209)
#plt.axis(ymax = 0.001)
plt.grid(True)
plt.savefig(f_out)
plt.close()
