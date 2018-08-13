# simulate a hodgkin-huxley model in NEURON
# measure the speed and accuracy with increasing time-step


from neuron import h, gui
import numpy as np
from matplotlib import pyplot
import time
from pathlib import Path


benchmarks_file = "neuron_HH_benchmark1.csv"


my_file1 = Path(benchmarks_file)
if my_file1.is_file():
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

# set up simulation
h.dt        = 0.1 # ms
h.tstop     = 30000 # ms

tic         = time.perf_counter() # s
h.run()
toc         = time.perf_counter() # s

# set up vectors to hold outputs
dt = [0.0010, 0.0020, 0.0040, 0.0050, 0.0080, 0.0100, 0.0200, 0.0250, .05, .1] # ms




S  = np.zeros((len(dt), 1))

# perform the simulation
for ii in range(0, len(dt)):
    percent = 100*ii/len(dt)
    print('percent complete:  ' + repr(percent) + '%')


    # set up independent parameter
    h.dt = dt[ii]
    h.tstop  = 30000 # ms

    # set up recording variable
    V = h.Vector()
    V.record(soma(0.5)._ref_v)
    T = h.Vector()
    T.record(h._ref_t)


    # perform simulation & capture time
    tic = time.perf_counter() # s
    h.run()
    toc = time.perf_counter() # s


    np.save('neuron_HH_raw' + str(ii+1),V)
    np.save('neuron_HH_raw_time' + str(ii+1),T)

    # process simulation time
    sim_time = (toc - tic) * 1000; # ms
    S[ii]        = h.tstop / sim_time # unitless



# save the results
np.savetxt(benchmarks_file, S, delimiter=",")



exit()