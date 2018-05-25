## Benchmark Test #1
# single-compartment, Hodgkin-Huxley
# test speed and accuracy with increasing time-step

# set up vectors to hold outputs
dt              = np.array([0.0010, 0.0020, 0.0040, 0.0050, 0.0080, 0.0100,
                0.0200, 0.0250, 0.0400, 0.0500, 0.1000, 0.1250, 0.2000 0.2500,
                0.5000, 1.0000])
sim_time        = np.zeros((len(dt), 1))
r2              = np.zeros((len(dt), 1))

# perform the simulation
for ii in range(1, len(dt)):
    h.dt = dt[ii]
    tic = time.clock()
    h.run()
    toc = time.clock() - tic
    sim_dt[ii] = toc;
