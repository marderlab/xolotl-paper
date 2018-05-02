from neuron import h, gui
import time

print(time.clock())
# create sections
soma = h.Section(name = 'soma')
h.psection(sec=soma)

# set the size of the soma
soma.L = 400
soma.diam = 50
print('surface area of the soma = {}'.format(soma(0.5).area()))

# split into 101 compartments
soma.nseg = 101
h.psection(soma)

# add Hodgkin-Huxley conductances
soma.insert('hh')

# set up output vectors
v_vec = h.Vector()        # Membrane potential vector
t_vec = h.Vector()        # Time stamp vector
v_vec.record(soma(0.5)._ref_v)
t_vec.record(h._ref_t)
h.tstop = 1000.0 # s

# run simulation
h.run()
print(time.clock())

# visualize
from matplotlib import pyplot
pyplot.figure(figsize=(8,4)) # Default figsize is (8,6)
pyplot.plot(t_vec, v_vec)
pyplot.xlabel('time (ms)')
pyplot.ylabel('mV')
pyplot.show()
