# simulate a stomatogastric neuron model in NEURON
# measure the speed and accuracy with increasing simulation time

# import the graphical interface
from neuron import h, gui
# import arrays and graphics
import numpy as np
from matplotlib import pyplot
import time

# create the neuron
soma = h.Section(name='soma');

# set the size of the soma
soma.L = 28.209; # microns
soma.diam   = 28.209; # microns

# set up the capacitance
soma.cm     = 1; # μF/cm^2

# add conductances from Liu et al 1998
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
soma(0.5).na.Erev           = 50;
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
h.tstop     = 10000 # ms

tic         = time.perf_counter() # s
h.run()
toc         = time.perf_counter() # s

# set up vectors to hold outputs
t_end = all_t_end = np.array([1, 2, 3, 4, 5, 7, 10, 13, 17, 22, 29, 39, 52, 69,
91, 121, 160, 212, 281, 373, 494, 655, 869, 1151, 1526, 2024, 2683, 3556, 4715,
6251, 8286, 10985, 14563, 19307, 25595, 33932, 44984, 59636, 79060, 104811, 138950,
184207, 244205, 323746, 429193, 568987, 754312, 1000000]) # ms

sim_time        = np.zeros((len(t_end),1))
S               = np.zeros((len(t_end),1))

# perform the simulation
for ii in range(0,len(t_end)):
    percent = 100*ii/len(t_end)
    print('percent complete:  ' + repr(percent) + '%')
    h.tstop         = t_end[ii]
    tic             = time.perf_counter() # s
    h.run()
    toc             = time.perf_counter() # s
    sim_time[ii]    = (toc-tic) * 1000; # ms
    S[ii]           = t_end[ii] / sim_time[ii] # unitless

# save the results
np.savetxt("neuron_STG_benchmark2.csv", S, delimiter=",")
