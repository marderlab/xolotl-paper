
x.add('AB','compartment','A',.06)
x.AB.add('Kd','gbar', 300);
n = floor(x.t_end/x.sim_dt);
V_clamp = repmat(20,n,1);
V_clamp(1:1e3) = -60;
x.V_clamp = V_clamp;
I = x.integrate;