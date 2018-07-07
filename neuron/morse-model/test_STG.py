# import the graphical interface
from neuron import h, gui
# import arrays and graphics
import numpy as np
from matplotlib import pyplot
import time

# create the neuron
soma        = h.Section(name='soma');

# set the size of the soma
soma.L      = 400; # microns
soma.diam   = 50; # microns

# set up the capacitance
soma.cm     = 1; # μF/cm^2

# add conductances from Liu et al. 1998
soma.insert('na')
soma.insert('cat')
soma.insert('cas')
soma.insert('ka')
soma.insert('kca')
soma.insert('kd')
soma.insert('h')
soma.insert('pas')

# add calcium buffering
soma.insert('cad')

# set maximal conductances
soma(0.5).pas.g             = 0.01 # uS/nF

# set reversal potentials
soma(0.5).pas.e             = -50;

# check to make sure everything is set up properly
h.psection(sec=soma)

# set up recording variables
v_vec       = h.Vector()
t_vec       = h.Vector()
v_vec.record(soma(0.5)._ref_v)
t_vec.record(h._ref_t)

# set up simulation
h.dt        = 0.1 # ms
h.tstop     = 30000 # ms

# perform simulation
tic         = time.perf_counter() # s
h.run()
toc         = time.perf_counter() # s

print("This simulation took {} seconds".format(toc-tic))
print("Speed factor: {}".format(h.tstop/1000/(toc-tic)))

# plot the voltage trace
pyplot.figure(figsize=(8,4)) # Default figsize is (8,6)
pyplot.plot(t_vec, v_vec)
pyplot.xlabel('time (ms)')
pyplot.ylabel('mV')
pyplot.show()
