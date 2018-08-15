
x.add('compartment','AB','A',.06)
x.AB.add('Kd','gbar', 300);
n = floor(x.t_end/x.sim_dt);
V_clamp = zeros(n,1);
V_clamp(1:1e4) = -60;
x.V_clamp = V_clamp;
I_clamp = x.integrate;