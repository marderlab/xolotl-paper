## Benchmark Test #1
# single-compartment, Hodgkin-Huxley
# test speed with increasing simulation time

import numpy as np
from neuron import h, gui
import time

# execute the main NEURON file
import neuron_HH

# set up vectors to hold outputs
t_end           = np.round(np.logspace(1, 6, num=20))
sim_time        = np.zeros((len(t_end),1))

# perform the simulation
for ii in range(1,len(t_end)):
    percent = 100*ii/len(t_end)
    print('percent complete:  ' + repr(percent) + '%')
    h.tstop = t_end[ii]
    tic = time.clock()
    h.run()
    toc = time.clock() - tic
    sim_time[ii] = toc;

# save the results
np.savetxt("neuron_benchmark1.csv", sim_time, delimiter=",")
