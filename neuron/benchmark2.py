## Benchmark Test #2
# single-compartment, Hodgkin-Huxley
# test speed with increasing simulation time

# execute the main neuron file
exec("neuron_HH.py")

# set up vectors to hold outputs
t_end           = np.round(np.logspace(1, 1e6, num=20))
sim_time        = np.zeros((len(t_end),1))

# perform the simulation
for ii in range(1,len(t_end)):
    h.tspan = t_end[ii]
    tic = time.clock()
    h.run()
    toc = time.clock() - tic
    sim_dt[ii] = toc;

# save the results
np.savetxt("neuron_benchmark2.csv", sim_dt, delimiter=",")
