%% Figure 7: Benchmarking Xolotl against DynaSim and NEURON

% create figure
fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;

% speed versus time-step & accuracy vs. time-step
ax(1) = subplot(1,3,1); hold on
ax(1).Tag = 'Q vs t_end';
% % accuracy vs. time-step
% ax(2) = subplot(1,3,2); hold on
% ax(2).Tag = 'Q vs. dt & r2 vs. dt';
% % speed versus time span
% ax(3) = subplot(1,3,3); hold on
% ax(3).Tag = 'Q vs. t_end';

% set up xolotl object
x = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);

t_end = 5e3;
x.t_end = t_end;

% set up DynaSim equation block
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

%% Benchmark Test #1
% simulate a hodgkin-huxley model neuron over a series of simulation times

t_end   = round(logspace(1,6,20));
Qfactor = NaN(length(t_end), 4);

% test xolotl

% set up simulation parameters for xolotl
x.sim_dt = 0.1; % ms
x.dt    = 0.1; % ms

% perform benchmarking
for ii = 1:length(t_end)
  textbar(ii, length(t_end))
  % set the end time
  x.t_end = t_end(ii);
  % begin timing
  tic;
  V = x.integrate(0.2);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor(ii, 1) = t_end(ii) / 1e3 / t_sim;
end

% test DynaSim

for ii = 1:length(t_end)
  textbar(ii, length(t_end))
  % begin timing
  tic;
  data = dsSimulate(equations, 'solver', 'rk2', 'tspan', [0 t_end(ii)], 'dt', 0.1, 'compile_flag', 0);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor(ii, 2) = t_end(ii) / 1e3 / t_sim;
end

% plot benchmark test #1

NEURON_data = csvread('~/code/simulation-environment-paper/neuron/neuron_benchmark1.csv');
return
plot(ax(1), t_end, Qfactor, '-o')
xlabel(ax(1), 'simulation time (ms)')
set(ax(1), 'XScale','log','YScale','log', 'XLim', [0 1.01e7], 'XTick', [1e1 1e4 1e7])
ylabel(ax(1), 'speed factor')
leg = legend(ax(1), {'xolotl', 'DynaSim', 'BRIAN 2', 'NEURON'}, 'Location', 'EastOutside');

% beautify
prettyFig('fs', 12, 'plw', 3)

% remove boxes around subplots
for ii = 1:length(ax)
  box(ax(ii), 'off')
end

% fix the sizing and spacing
pos = [...
0.0746    0.4070    0.2121    0.4937;
0.3554    0.4070    0.2121    0.4937;
0.6362    0.4070    0.2121    0.4937];

for ii = 1:length(ax)
  ax(ii).Position = pos(ii, :);
end

% label the subplots
% labelFigure('capitalise', true)

% break the axes
deintersectAxes(ax(1:3))
