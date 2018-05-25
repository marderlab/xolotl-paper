# import the graphical interface
from neuron import h, gui
# import arrays and graphics
import numpy as np
from matplotlib import pyplot

# create the neuron
soma        = h.Section(name='soma');
h.psection(sec=soma)

# set the size of the soma
soma.L      = 28.209 # microns
soma.diam   = 28.209 # microns
print('surface area of the soma = {}'.format(soma(0.5).area()))

# set up the capacitance
soma.cm     = 1 # uF/cm^2

# add conductances from Liu et al. 1998
soma.insert('pas')
soma.insert('liu_Kd')
soma.insert('liu_NaV')

# set up maximal conductances
soma.pas.gbar       = 1 / 1e4 # S/cm^2
soma.liu_NaV.gbar   = 1000 / 1e4 # S/cm^2
soma.liu_Kd.gbar    = 300 / 1e4 # S/cm^2

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
h.dt    = 0.05/1000 # s
h.tstop = 100.0 # s
h.secondorder = 2 # use Crank-Nicholson
