# implement a Hodgkin-Huxley model in BRIAN 2
# use for benchmarking xolotl

"""
# Notes:
- Adapted from A Soplata's benchmarking for DynaSim
    https://github.com/asoplata/dynasim-benchmark-brette-2007
- Goodman D, Brette R. Brian: a simulator for spiking neural networks in Python.
Frontiers in Neuroinformatics 2008;2. doi:10.3389/neuro.11.005.2008.
"""

from brian2 import *
set_device('cpp_standalone', build_on_run=False) # compile and use C++ code
prefs.codegen.cpp.extra_compile_args = ['-w', '-O3', '-ffast-math', '-march=native'] # optimized for speed

# Parameters
cells = 1

# compartment parameters
area        = 0.1*mmeter**2
Cm          = 10*nfarad*mmeter**-2

# maximal conductances
gLeak       = (12)*usiemens*mmeter**-2
gNa         = (1000)*usiemens*mmeter**-2
gKd         = (300)*usiemens*mmeter**-2

# reversal potentials
ELeak       = -50*mV
EKd         = -80*mV
ENa         = 50*mV

## Benchmark #1

import numpy as np
import time

# parameters
t_end       = 5000
dt = np.array([0.0010, 0.0020, 0.0040, 0.0050, 0.0080, 0.0100, 0.0200, 0.0250,
 0.0400, 0.0500, 0.1000, 0.1250, 0.2000, 0.2500, 0.5000, 1.0000]) # ms

# set up vectors to hold outputs
Vtrace = np.empty((int(np.round(t_end/dt[1]+1)),len(dt)))
Vtrace[:,:] = np.nan
sim_time        = np.zeros((len(dt),1))
speed_factor    = np.zeros((len(dt),1))

# the model
eqs = Equations('''
dv/dt = (gLeak*(ELeak-v)-gNa*(m*m*m)*h*(v-ENa)-gKd*(n*n*n*n)*(v-EKd) + 0.2*nA/area)/Cm : volt
dm/dt = (minf - m)/taum : 1
dn/dt = (ninf - n)/taun : 1
dh/dt = (hinf - h)/tauh : 1
minf  = 1.0/(1.0+exp((v+25.5*mV)/(-5.29*mV))) : 1
hinf  = 1.0/(1.0+exp((v+48.9*mV)/(5.18*mV))) : 1
ninf  = 1.0/(1.0+exp((v+12.3*mV)/(-11.8*mV))) : 1
taum  = (1.32-1.26/(1+exp((v+120.0*mV)/(-25.0*mV))))*ms : second
tauh  = ((0.67/(1.0+exp((v+62.9*mV)/(-10.0*mV))))*(1.5+1.0/(1.0+exp((v+34.9*mV)/(3.6*mV)))))*ms : second
taun  = (7.2-6.4/(1.0+exp((v+(28.3*mV))/(-19.2*mV))))*ms : second
''')

P = NeuronGroup(cells, model=eqs, method='exponential_euler')
P.add_attribute('area')
P.area = area

# Initialization
P.v = '-65*mV'
P.m = '0'
P.h = '1'
P.n = '0'

# record the voltage during the simulation
M = StateMonitor(P, 'v', record=True)

net = Network(P)
net.add(M)

defaultclock.dt = 0.01*ms

device.reinit()                         # some
device.activate(build_on_run=False)     # kind of
device.build()                          # sorcery
tic = time.perf_counter() # s
net.run(5000*ms)
toc = time.perf_counter() - tic # s
print('time elapsed = ' + repr(1000*toc) + ' ms')

# perform the simulation
for ii in range(1,len(dt)):
    percent = 100*ii/len(dt)
    print('percent complete:  ' + repr(percent) + '%')

    # set up independent parameter
    defaultclock.dt = dt[ii]*ms

    # perform simulation & capture time
    device.reinit()                         # some
    device.activate(build_on_run=False)     # kind of
    device.build()                          # sorcery
    tic = time.perf_counter() # s
    run(5000*ms)
    toc = time.perf_counter() - tic # s

    # save voltage trace
    V = M.v[0]/mV
    for qq in range(0,len(V)-1):
        Vtrace[qq,ii] = V[qq]

# process simulation time
sim_time[ii] = toc*1000; # ms
speed_factor[ii] = t_end / sim_time[ii] # unitless

np.savetxt("brian_benchmark1.csv", speed_factor, delimiter=",")
np.savetxt("brian_benchmark1_raw.csv", Vtrace, delimiter=",")
