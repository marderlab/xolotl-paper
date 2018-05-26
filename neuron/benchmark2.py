## Benchmark Test #2
# single-compartment, Hodgkin-Huxley
# test speed with increasing simulation time

# set up vectors to hold outputs
t_end           = [10, 18, 34, 62, 113, 207, 379, 695, 1274, 2336, 4281,
                7848, 14384, 26367, 48329, 88587, 162378, 297635, 545559, 1000000]
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
