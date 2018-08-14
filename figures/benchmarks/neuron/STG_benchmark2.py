# simulate a stomatogastric neuron model in NEURON
# measure the speed and accuracy with increasing simulation time

# import the graphical interface
from neuron import h, gui
# import arrays and graphics
import numpy as np
from matplotlib import pyplot
import time
from pathlib import Path

benchmarks_file = "neuron_STG_benchmark2.csv"

my_file1 = Path(benchmarks_file)
if my_file1.is_file():
    print("It looks like the benchmark is already done, so aborting...")
    exit()


# create the neuron
soma        = h.Section(name='soma');

# set the size of the soma
soma.L      = 70.6928; # microns
soma.diam   = 70.6928*2; # microns
# surface area = 62800 um^2 = 0.000628 cm^2

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
soma(0.5).na.gbar           = 1831.2/10000 # S/cm^2
soma(0.5).cat.gbar          = 22.93/10000
soma(0.5).cas.gbar          = 27.07/10000
soma(0.5).acurrent.gbar     = 246.02/10000
soma(0.5).kca.gbar          = 979.94/10000
soma(0.5).kd.gbar           = 610.03/10000
soma(0.5).hcurrent.gbar     = 10.1/10000
soma(0.5).pas.g             = 0.99045/10000

# set reversal potentials
soma(0.5).na.Erev           = 30; # mV
soma(0.5).acurrent.Erev     = -80;
soma(0.5).kca.Erev          = -80;
soma(0.5).kd.Erev           = -80;
soma(0.5).hcurrent.Erev     = -20;
soma(0.5).pas.e             = -50;

# set up corrective stimulation
stim        = h.IClamp(soma(0.5))
stim.amp    = 0.2 # nA
stim.dur    = 10000 # ms

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
t_end = np.array([1, 2, 4, 9, 18, 38, 78, 162, 336, 695, 1438, 2976,
6158, 12743, 26367, 54556, 112884, 233572, 483293, 1000000]) # ms

S               = np.zeros((len(t_end),1))

# perform the simulation
for ii in range(0,len(t_end)):
    percent = 100*ii/len(t_end)
    print('percent complete:  ' + repr(percent) + '%')
    h.tstop  = t_end[ii]
    stim.dur = t_end[ii]


    tic             = time.perf_counter() # s
    h.run()
    toc             = time.perf_counter() # s


    sim_time    = (toc-tic) * 1000; # ms
    S[ii]  = t_end[ii] / sim_time # unitless

# save the results
np.savetxt(benchmarks_file, S, delimiter=",")


exit()