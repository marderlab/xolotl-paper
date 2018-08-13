# simulate a hodgkin-huxley model in NEURON
# measure the speed and accuracy with increasing time-step


from neuron import h, gui
import numpy as np
from matplotlib import pyplot
import time
from pathlib import Path

raw_file = "neuron_HH_benchmark1_raw.csv"
benchmarks_file = "neuron_HH_benchmark1.csv"


my_file1 = Path(benchmarks_file)
my_file2 = Path(raw_file)
if my_file1.is_file() and my_file2.is_file():
    print("It looks like the benchmark is already done, so aborting...")
    exit()


# create the neuron
soma        = h.Section(name='soma');

# set the size of the soma
soma.L      = 28.209; # microns
soma.diam   = 28.209; # microns

# set up the capacitance
soma.cm     = 1; # μF/cm^2

# add conductances from Liu et al. 1998
soma.insert('pas')
soma.insert('na')
soma.insert('kd')

# set maximal conductances
soma(0.5).pas.g = 1/10000
soma(0.5).na.gbar  = 1000/10000
soma(0.5).kd.gbar  = 300/10000

# check to make sure everything is set up properly
h.psection(sec=soma)

# set up injected current
stim        = h.IClamp(soma(0.5))
stim.amp    = 0.2 # nA
stim.dur    = 30000 # ms

# set up recording variables
v_vec       = h.Vector()
t_vec       = h.Vector()
v_vec.record(soma(0.5)._ref_v)
t_vec.record(h._ref_t)

# set up simulation
h.dt        = 0.1 # ms
h.tstop     = 30000 # ms

tic         = time.perf_counter() # s
h.run()
toc         = time.perf_counter() # s

# set up vectors to hold outputs
dt          = np.array([0.0010, 0.0020, 0.0040, 0.0050, 0.0080, 0.0100, 0.0200, 0.0250, 0.0400, 0.0500, 0.1000, 0.1250, 0.2000, 0.2500, 0.5000, 1.0000]) # ms
Vtrace      = np.empty((int(np.round(h.tstop/dt[0]+1)),len(dt)))
Vtrace[:,:] = np.nan

sim_time    = np.zeros((len(dt), 1))
S           = np.zeros((len(dt), 1))

# perform the simulation
for ii in range(0, len(dt)):
    percent = 100*ii/len(dt)
    print('percent complete:  ' + repr(percent) + '%')

    # set up recording variable
    V = h.Vector()
    V.record(soma(0.5)._ref_v)

    # set up independent parameter
    h.dt = dt[ii]

    # perform simulation & capture time
    tic = time.perf_counter() # s
    h.run()
    toc = time.perf_counter() # s

    # save voltage trace
    for qq in range(0,len(V)-1):
        Vtrace[qq,ii] = V[qq]

    # process simulation time
    sim_time[ii] = (toc - tic) * 1000; # ms
    S[ii]        = h.tstop / sim_time[ii] # unitless


print('All simulations done, saving...')

# save the results
np.savetxt(benchmarks_file, S, delimiter=",")
np.savetxt(raw_file, Vtrace, delimiter=",")


exit()