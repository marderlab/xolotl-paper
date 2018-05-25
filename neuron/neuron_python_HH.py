

# run simulation
aaa = time.clock()
h.run()
print(time.clock()-aaa)

# visualize
from matplotlib import pyplot
pyplot.figure(figsize=(8,4)) # Default figsize is (8,6)
pyplot.plot(t_vec, v_vec)
pyplot.xlabel('time (s)')
pyplot.ylabel('mV')
pyplot.show()
