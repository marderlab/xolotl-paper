# simulate a stomatogastric neuron model in NEURON
# measure the speed and accuracy with increasing number of compartments

import numpy as np
from neuron import h, gui
import time

# set up vectors to hold outputs
nComps = np.array([1, 2, 4, 8, 16, 32, 64, 128, 250, 500, 1000])

sim_time        = np.zeros((len(nComps),1))
S               = np.zeros((len(nComps),1))
sec             = []
stim            = []

# perform the simulation
for ii in range(0,len(nComps)):
    percent = 100*ii/len(nComps)
    print('percent complete:  ' + repr(percent) + '%')
    for qq in range(0,nComps[ii]-1):
        # create the neuron
        compName = 'comp #'+repr(qq)
        sec.append(h.Section(name=compName))

        # set the size of the soma
        sec[qq].L      = 70.6928; # microns
        sec[qq].diam   = 70.6928*2; # microns

        # set up the capacitance
        sec[qq].cm     = 1 # uF/cm^2

        # add conductances from Liu et al. 1998
        sec[qq].insert('na')
        sec[qq].insert('cat')
        sec[qq].insert('cas')
        sec[qq].insert('acurrent')
        sec[qq].insert('kca')
        sec[qq].insert('kd')
        sec[qq].insert('hcurrent')
        sec[qq].insert('pas')

        # add calcium buffering
        sec[qq].insert('cad')

        # set maximal conductances
        sec[qq](0.5).na.gbar           = 1831.2/10000 # S/cm^2
        sec[qq](0.5).cat.gbar          = 22.93/10000
        sec[qq](0.5).cas.gbar          = 27.07/10000
        sec[qq](0.5).acurrent.gbar     = 246.02/10000
        sec[qq](0.5).kca.gbar          = 979.94/10000
        sec[qq](0.5).kd.gbar           = 610.03/10000
        sec[qq](0.5).hcurrent.gbar     = 10.1/10000
        sec[qq](0.5).pas.g             = 0.99045/10000

        # set reversal potentials
        sec[qq](0.5).na.Erev           = 30; # mV
        sec[qq](0.5).acurrent.Erev     = -80;
        sec[qq](0.5).kca.Erev          = -80;
        sec[qq](0.5).kd.Erev           = -80;
        sec[qq](0.5).hcurrent.Erev     = -20;
        sec[qq](0.5).pas.e             = -50;

        # set up corrective stimulation
        stim.append(h.IClamp(sec[qq](0.5)))
        stim[qq].amp = 0.2 # nA
        stim[qq].dur = 30000 # ms

    # set up simulation
    h.dt    = 0.1 # ms
    h.tstop = 30000.0 # ms

    # run simulation
    tic = time.perf_counter() # s
    h.run()
    toc = time.perf_counter() # s
    sim_time[ii] = (toc - tic) * 1000; # ms
    S[ii] = h.tstop / sim_time[ii] # unitless

# save the results
np.savetxt("neuron_STG_benchmark3.csv", S, delimiter=",")

exit()
