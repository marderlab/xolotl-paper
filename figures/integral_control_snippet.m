

% add controllers to conductances
x.AB.NaV.add('IntegralController');
x.AB.CaT.add('IntegralController');
% and so on...

% configure controller parameters
x.set('*tau_m',1e4./[1 .22 .18 .08 8 5 15])
x.set('*Controller.m',1e-1+1e-2*rand(7,1))

x.t_end = .5e3;
[~,Ca0,C0] = x.integrate;
x.snapshot('before');

x.t_end = 9.5e3;
[~,Ca1,C1] = x.integrate;
x.snapshot('during');

x.t_end = 990e3;
[~,Ca2,C2] = x.integrate;
x.snapshot('after');