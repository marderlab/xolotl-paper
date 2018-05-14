x = xolotl;
x.add('HH', 'compartment', 'Cm', 10);
x.HH.add('liu/NaV', 'gbar', 1000);
x.HH.add('liu/Kd', 'gbar', 300);
x.HH.add('Leak', 'gbar', 1);
x.plot;(0.1);
x.show(x.HH.find('conductance'))
