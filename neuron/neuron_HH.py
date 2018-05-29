# import the graphical interface
from neuron import h, gui
# import arrays and graphics
import numpy as np
from matplotlib import pyplot

# create the neuron
soma        = h.Section(name='soma');
# h.psection(sec=soma)

# set the size of the soma
soma.L      = 28.209 # microns
soma.diam   = 28.209 # microns
print('surface area of the soma = {}'.format(soma(0.5).area()))

# set up the capacitance
soma.cm     = 1 # uF/cm^2

# add conductances from Liu et al. 1998
soma.insert('pas')

soma.insert('na')
soma.insert('kd')

# set maximal conductances
soma(0.5).pas.g = 0.0001

h.psection(sec=soma)

# set up injected current
stim = h.IClamp(soma(0.5))
stim.amp = 0.2 # nA
stim.dur = 5000 # ms

# set up recording variables
v_vec       = h.Vector()
t_vec       = h.Vector()
v_vec.record(soma(0.5)._ref_v)
t_vec.record(h._ref_t)

# set up simulation
h.dt    = 0.05
h.tstop = 1000.0 # ms
# h.secondorder = 2 # use Crank-Nicholson

h.run()

# visualize the results
pyplot.figure(figsize=(8,4)) # Default figsize is (8,6)
pyplot.plot(t_vec, v_vec)
pyplot.xlabel('time (ms)')
pyplot.ylabel('mV')
pyplot.show()
