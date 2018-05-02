# import the graphical interface (might not work)
from neuron import h, gui

# create a model neuron
soma   = h.Section(name='soma')

# view the hoc properties
h.psection()
# view the python properties
dir(soma)
# view the docstring
help(soma.connect)

# add a passive leak channel
soma.insert('pas')

# insert an alpha synapse
# this is a point process
asyn = h.AlphaSynapse(soma(0.5))
dir(asyn)
print("asyn.e = {}".format(asyn.e))
print("asyn.gmax = {}".format(asyn.gmax))
print("asyn.onset = {}".format(asyn.onset))
print("asyn.tau = {}".format(asyn.tau))

# set up recording variables
v_vec = h.Vector()
t_vec = h.Vector()
v_vec.record(soma(0.5)._ref_v)
t_vec.record(h._ref_t)

# run the simulation
h.tstop = 40.0
h.run()

from matplotlib import pyplot
pyplot.figure(figsize=(8,4)) # Default figsize is (8,6)
pyplot.plot(t_vec, v_vec)
pyplot.xlabel('time (ms)')
pyplot.ylabel('mV')
pyplot.show()
