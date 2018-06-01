## Benchmark Test #1
# single-compartment, Hodgkin-Huxley
# test speed with increasing time-step

import numpy as np
import time

# execute the main NEURON file

################################################################################
################################################################################
################################################################################

# import the graphical interface
from neuron import h, gui
# import arrays and graphics
import numpy as np
from matplotlib import pyplot

# create the neuron
soma        = h.Section(name='soma');
# h.psection(sec=soma)

# set the size of the soma
soma.L      = 28.209 # microns
soma.diam   = 28.209 # microns
print('surface area of the soma = {}'.format(soma(0.5).area()))

# set up the capacitance
soma.cm     = 1 # uF/cm^2

# add conductances from Liu et al. 1998
soma.insert('pas')

soma.insert('na')
soma.insert('kd')

# set maximal conductances
soma(0.5).pas.g = 0.0001

h.psection(sec=soma)

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
h.dt    = 0.1 # ms
h.tstop = 1000.0 # ms
# h.secondorder = 2 # use Crank-Nicholson

h.run()

################################################################################
################################################################################
################################################################################

t_end           = 5000.0 # ms
h.tstop         = t_end

# set up vectors to hold outputs
dt = np.array([0.0010, 0.0020, 0.0040, 0.0050, 0.0080, 0.0100, 0.0200, 0.0250,
 0.0400, 0.0500, 0.1000, 0.1250, 0.2000, 0.2500, 0.5000, 1.0000]) # ms
Vtrace = np.empty((int(np.round(h.tstop/dt[1]+1)),len(dt)))
Vtrace[:,:] = np.nan

sim_time        = np.zeros((len(dt),1))
speed_factor    = np.zeros((len(dt),1))


# perform the simulation
for ii in range(1,len(dt)):
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
    toc = time.perf_counter() - tic # s

    # save voltage trace
    for qq in range(0,len(V)-1):
        Vtrace[qq,ii] = V[qq]

    # process simulation time
    sim_time[ii] = toc*1000; # ms
    speed_factor[ii] = t_end / sim_time[ii] # unitless

# save the results
np.savetxt("neuron_benchmark1.csv", speed_factor, delimiter=",")
np.savetxt("neuron_benchmark1_raw.csv", Vtrace, delimiter=",")
