%% Figure 1: Minimal Code, Maximal Output
x     = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01)
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50)
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80)
x.HH.add('Leak', 'gbar', 1, 'E', -50)
x.show(x.HH.find('conductance'))
x.plot(0.08)
