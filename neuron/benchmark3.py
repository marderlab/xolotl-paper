## Benchmark Test #3
# single-compartment, Hodgkin-Huxley
# test speed with increasing number of compartments

import numpy as np
from neuron import h, gui
import time

# set up vectors to hold outputs
nComps = np.array([1, 2, 4, 8, 16, 32, 64, 128, 250, 500, 1000])

sim_time        = np.zeros((len(nComps),1))
speed_factor    = np.zeros((len(nComps),1))
sec             = []
stim            = []

# perform the simulation
for ii in range(1,len(nComps)):
    percent = 100*ii/len(nComps)
    print('percent complete:  ' + repr(percent) + '%')
    for qq in range(0,nComps[ii]-1):
        # create the neuron
        compName = 'comp #'+repr(qq)
        sec.append(h.Section(name=compName))

        # set the size of the soma
        sec[qq].L      = 28.209 # microns
        sec[qq].diam   = 28.209 # microns

        # set up the capacitance
        sec[qq].cm     = 1 # uF/cm^2

        # add conductances from Liu et al. 1998
        sec[qq].insert('pas')

        sec[qq].insert('na')
        sec[qq].insert('kd')

        # set maximal conductances
        sec[qq](0.5).pas.g = 0.0001

        # set up injected current
        stim.append(h.IClamp(sec[qq](0.5)))
        stim[qq].amp = 0.2 # nA
        stim[qq].dur = 5000 # ms

    # set up simulation
    h.dt    = 0.1 # ms
    h.tstop = 5000.0 # ms

    # run simulation
    tic = time.perf_counter() # s
    h.run()
    toc = time.perf_counter() - tic # s
    sim_time[ii] = toc*1000; # ms
    speed_factor[ii] = h.tstop / sim_time[ii] # unitless

# save the results
np.savetxt("neuron_benchmark3.csv", speed_factor, delimiter=",")
