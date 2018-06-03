"""
# Notes:
- This simulation seeks to emulate the COBAHH benchmark simulations of (Brette
  et al. 2007) using the Brian2 simulator for speed benchmark comparison to
  DynaSim. However, this simulation does NOT include synapses, for better
  comparison to Figure 5 of (Goodman and Brette, 2008) - although it uses the
  COBAHH model of (Brette et al. 2007), not CUBA.
- The time taken to simulate will be indicated in the stdout log file
'~/batchdirs/brian2_benchmark_COBAHH_nosyn_compiled_8000/pbsout/brian2_benchmark_COBAHH_nosyn_compiled_8000.out'
- Note that this code has been slightly modified from the original (Brette et
  al. 2007) benchmarking code, available here on ModelDB:
  https://senselab.med.yale.edu/modeldb/showModel.cshtml?model=83319
  in order to work with version 2 of the Brian simulator (aka Brian2), and also
  modified to change the model being benchmarked, etc.
# References:
- Brette R, Rudolph M, Carnevale T, Hines M, Beeman D, Bower JM, et al.
Simulation of networks of spiking neurons: A review of tools and strategies.
Journal of Computational Neuroscience 2007;23:349–98.
doi:10.1007/s10827-007-0038-6.
- Goodman D, Brette R. Brian: a simulator for spiking neural networks in Python.
Frontiers in Neuroinformatics 2008;2. doi:10.3389/neuro.11.005.2008.
"""

from brian2 import *
set_device('cpp_standalone')
prefs.codegen.cpp.extra_compile_args = ['-w', '-O3', '-ffast-math', '-march=native']

# Parameters
cells = 8000

defaultclock.dt = 0.01*ms
area = 20000*umetre**2
Cm = (1*ufarad*cmetre**-2) * area
gl = (5e-5*siemens*cmetre**-2) * area

El = -60*mV
EK = -90*mV
ENa = 50*mV
g_na = (100*msiemens*cmetre**-2) * area
g_kd = (30*msiemens*cmetre**-2) * area
VT = -63*mV
# # Time constants
# taue = 5*ms
# taui = 10*ms
# # Reversal potentials
# Ee = 0*mV
# Ei = -80*mV
# we = 6*nS  # excitatory synaptic weight
# wi = 67*nS  # inhibitory synaptic weight

# The model
eqs = Equations('''
dv/dt = (gl*(El-v)-
         g_na*(m*m*m)*h*(v-ENa)-
         g_kd*(n*n*n*n)*(v-EK))/Cm : volt
dm/dt = alpha_m*(1-m)-beta_m*m : 1
dn/dt = alpha_n*(1-n)-beta_n*n : 1
dh/dt = alpha_h*(1-h)-beta_h*h : 1
alpha_m = 0.32*(mV**-1)*(13*mV-v+VT)/
         (exp((13*mV-v+VT)/(4*mV))-1.)/ms : Hz
beta_m = 0.28*(mV**-1)*(v-VT-40*mV)/
        (exp((v-VT-40*mV)/(5*mV))-1)/ms : Hz
alpha_h = 0.128*exp((17*mV-v+VT)/(18*mV))/ms : Hz
beta_h = 4./(1+exp((40*mV-v+VT)/(5*mV)))/ms : Hz
alpha_n = 0.032*(mV**-1)*(15*mV-v+VT)/
         (exp((15*mV-v+VT)/(5*mV))-1.)/ms : Hz
beta_n = .5*exp((10*mV-v+VT)/(40*mV))/ms : Hz
''')
dv/dt = (gl*(El-v)+ge*(Ee-v)+gi*(Ei-v)-
dge/dt = -ge*(1./taue) : siemens
dgi/dt = -gi*(1./taui) : siemens

P = NeuronGroup(cells, model=eqs, threshold='v>-20*mV', refractory=3*ms,
                method='euler')
proportion=int(0.8*cells)
Pe = P[:proportion]
Pi = P[proportion:]
# Ce = Synapses(Pe, P, on_pre='ge+=we')
# Ci = Synapses(Pi, P, on_pre='gi+=wi')
# Ce.connect(p=0.98)
# Ci.connect(p=0.98)

# Initialization
P.v = 'El + (randn() * 5 - 5)*mV'
# P.ge = '(randn() * 1.5 + 4) * 10.*nS'
# P.gi = '(randn() * 12 + 20) * 10.*nS'

# Record a few traces
trace = StateMonitor(P, 'v', record=[1, 10, 100])
totaldata = StateMonitor(P, 'v', record=True)

run(0.5 * second, report='text')

# plot(trace.t/ms, trace[1].v/mV)
# plot(trace.t/ms, trace[10].v/mV)
# plot(trace.t/ms, trace[100].v/mV)
# xlabel('t (ms)')
# ylabel('v (mV)')
# show()

# print("Saving TC cell voltages!")
# numpy.savetxt("foo_totaldata.csv", totaldata.v/mV, delimiter=",")
