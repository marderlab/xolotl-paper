## Benchmark Test #1
# single-compartment, Hodgkin-Huxley
# test speed with increasing simulation time

import numpy as np
from neuron import h, gui
import time

# execute the main NEURON file
import neuron_HH

# set up vectors to hold outputs
t_end = np.array([10, 18, 34, 62, 113,  207,  379,  695, 1274, 2336, 4281, 7848,
14384, 26367, 48329, 88587, 162378,  297635, 545559, 1000000]) # ms


sim_time        = np.zeros((len(t_end),1))
speed_factor    = np.zeros((len(t_end),1))

# perform the simulation
for ii in range(1,len(t_end)):
    percent = 100*ii/len(t_end)
    print('percent complete:  ' + repr(percent) + '%')
    h.tstop = t_end[ii]
    tic = time.perf_counter() # s
    h.run()
    toc = time.perf_counter() - tic # s
    sim_time[ii] = toc/1000; # ms
    speed_factor[ii] = t_end[ii] / sim_time[ii] # unitless

# save the results
np.savetxt("neuron_benchmark1.csv", speed_factor, delimiter=",")
