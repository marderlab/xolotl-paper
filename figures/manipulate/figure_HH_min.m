

x.add('compartment', 'HH' ...
	'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000);
x.HH.add('liu/Kd', 'gbar', 300);
x.HH.add('Leak', 'gbar', 1);
x.I_ext = .2;
x.plot;
x.show({'liu/Kd','liu/NaV'})
