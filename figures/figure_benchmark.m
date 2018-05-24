%% Figure 7: Benchmarking Xolotl against DynaSim and NEURON


%% Benchmark Test #1
% simulate a hodgkin-huxley model neuron over a series of simulation times

t_end   = round(logspace(1,6,20));
Qfactor = NaN(length(t_end), 3);

% test xolotl

% set up xolotl object
x = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);

% set up simulation parameters for xolotl
x.dt    = 0.1; % ms

% perform benchmarking
for ii = 1:length(t_end)
  % set the end time
  x.t_end = t_end(ii);
  % begin timing
  tic;
  x.integrate(0.2);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor(ii, 1) = t_end(ii) / t_sim;
end

% test DynaSim

equations = { ...
  'gNa = 1000; gKd = 300; gLeak = 1; Cm = 10', ...
  'INa(v,m,h)=gNa.*m.^3.*h.*(v-50)',...
  'IKd(v,n)=gKd.*n.^4.*(v+80)',...
  'ILeak(v)=gLeak.*(v+50)',...
  'dv/dt=(0.2/0.01-INa(v,m,h)-IKd(v,n)-ILeak(v))/Cm;',...
  'v(0)=-65;m(0)=0;n(0)=0;h(0)=1',...
  'dm/dt=(minf(v)-m)/taum(v)',...
  'dh/dt=(hinf(v)-h)/tauh(v)',...
  'dn/dt=(ninf(v)-n)/taun(v)',...
  'minf(v)=1.0/(1.0+exp((v+25.5)/-5.29))',...
  'hinf(v)=1.0/(1.0+exp((v+48.9)/5.18))',...
  'ninf(v)=1.0/(1.0+exp((v+12.3)/-11.8))',...
  'taum(v)=1.32-1.26/(1+exp((v+120.0)/-25.0))',...
  'tauh(v)=(0.67/(1.0+exp((v+62.9)/-10.0)))*(1.5+1.0/(1.0+exp((v+34.9)/3.6)))',...
  'taun(v)=7.2-6.4/(1.0+exp((v+28.3)/-19.2))'};

for ii = 1:length(t_end)
  % begin timing
  tic;
  data = dsSimulate(equations, 'solver', 'rk2', 'tspan', [0 t_end(ii)], ...
    'dt', 0.1, 'compile_flag', 1);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor(ii, 2) = t_end(ii) / t_sim;
end

% plot the results

figure;
plot(t_end, Qfactor, '-o')
xlabel('Simulation time (ms)')
set(gca,'XScale','log','YScale','log','XTick',logspace(1,6,6))
ylabel('Speed (X realtime)')
legend({'xolotl', 'DynaSim'})

prettyFig();
