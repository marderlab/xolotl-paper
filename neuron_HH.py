from neuron import h, gui
import time

# create sections
soma = h.Section(name = 'soma')
h.psection(sec=soma)

# set the size of the soma
soma.L = 50
soma.diam = 25
print('surface area of the soma = {}'.format(soma(0.5).area()))

# split into 101 compartments
soma.nseg = 101
h.psection(soma)

# add Hodgkin-Huxley conductances
soma.insert('hh')
# inject current
stim = h.IClamp(soma(0.5))
stim.amp = 1.0;
stim.dur = 5000;

# set up output vectors
v_vec = h.Vector()        # Membrane potential vector
t_vec = h.Vector()        # Time stamp vector
v_vec.record(soma(0.5)._ref_v)
t_vec.record(h._ref_t)

# set up simulation
h.dt    = 0.05/1000 # s
h.tstop = 100.0 # s
h.secondorder = 2 # use Crank-Nicholson

# run simulation
aaa = time.clock()
h.run()
print(time.clock()-aaa)

# visualize
from matplotlib import pyplot
pyplot.figure(figsize=(8,4)) # Default figsize is (8,6)
pyplot.plot(t_vec, v_vec)
pyplot.xlabel('time (s)')
pyplot.ylabel('mV')
pyplot.show()
