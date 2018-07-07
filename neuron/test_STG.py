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
soma.insert('acurrent')
soma.insert('kca')
soma.insert('kd')
soma.insert('hcurrent')
soma.insert('pas')

# add calcium buffering
soma.insert('cad')

# set maximal conductances
soma(0.5).na.gbar           = 1831.2/10000
soma(0.5).cat.gbar          = 22.93/10000
soma(0.5).cas.gbar          = 27.07/10000
soma(0.5).acurrent.gbar     = 246.02/10000
soma(0.5).kca.gbar          = 979.94/10000
soma(0.5).kd.gbar           = 610.03/10000
soma(0.5).hcurrent.gbar     = 10.1/10000
soma(0.5).pas.g             = 0.99045/10000

# set reversal potentials
soma(0.5).na.Erev           = 30;
soma(0.5).acurrent.Erev     = -80;
soma(0.5).kca.Erev          = -80;
soma(0.5).kd.Erev           = -80;
soma(0.5).hcurrent.Erev     = -20;
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
h.tstop     = 5000 # ms

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
