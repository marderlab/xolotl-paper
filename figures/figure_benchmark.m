%% Figure 7: Benchmarking Xolotl against DynaSim and NEURON

% create figure
fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;

% speed versus time-step
ax(1) = subplot(1,3,1); hold on
ax(1).Tag = 'Q vs t_end';
% speed versus network size
ax(2) = subplot(1,3,2); hold on
ax(2).Tag = 'Q vs. nComps';
% accuracy vs. dt
ax(3) = subplot(1,3,3); hold on
ax(3).Tag = 'Accuracy';

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Benchmark Test #2
% simulate a hodgkin-huxley model neuron over a series of simulation times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% recover benchmark for BRIAN 2
% BRIAN_data = csvread('~/code/simulation-environment-paper/brian/brian_benchmark1.csv');

% recover benchmark for NEURON
NEURON_data = csvread('~/code/simulation-environment-paper/neuron/neuron_benchmark1.csv');

% plot benchmark 2
% Qfactor(:,3) = vectorise(BRIAN_data);
Qfactor(:,4) = vectorise(NEURON_data);

plot(ax(2), t_end, Qfactor, '-o')
xlabel(ax(2), 'simulation time (ms)')
set(ax(2), 'XScale','log','YScale','log', 'XLim', [0 1.01e7], 'XTick', [1e1 1e4 1e7])
ylabel(ax(2), 'speed factor')
% leg = legend(ax(2), {'xolotl', 'DynaSim', 'BRIAN 2', 'NEURON'}, 'Location', 'EastOutside');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Benchmark Test #3
% speed test over number of compartments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up general simulation parameters
t_end     = 5e3; % ms
dt        = 0.1; % ms
nComps    = [1, 2, 4, 8, 16, 32, 64, 128 250 500 1000];% 2000 4000 10000];
Qfactor_nComps = zeros(length(nComps),4);

% test xolotl

% set up simulation parameters for xolotl
x.dt      = dt;
x.sim_dt  = dt;
x.t_end   = t_end;

% perform benchmarking
for ii = 1:length(nComps)
  textbar(ii, length(nComps))
  % set up the xolotl object
  clear x
  x = xolotl;
  x.cleanup
  x.skip_hash = true;
  for qq = 1:nComps(ii)
    compName = ['HH' mat2str(qq)];
    x.add(compName, 'compartment', 'Cm', 10, 'A', 0.01);
    x.(compName).add('liu/NaV', 'gbar', 1000, 'E', 50);
    x.(compName).add('liu/Kd', 'gbar', 300, 'E', -80);
    x.(compName).add('Leak', 'gbar', 1, 'E', -50);
  end
  x.skip_hash = false;
  x.md5hash
  x.transpile; x.compile;
  Iext = 0.2 * ones(nComps(ii), 1);

  % begin timing
  tic;
  x.integrate(Iext);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor_nComps(ii, 1) = t_end / 1e3 / t_sim;
end

% test DynaSim

for ii = 1:length(nComps)
  textbar(ii, length(nComps))
  % set up the DynaSim 'specification'
  clear S
  S = struct; % holds the DynaSim population information
  S.population.name       = 'test';
  S.population.size       = nComps(ii);
  S.population.equations  = equations;

  % begin timing
  tic;
  dsSimulate(equations, 'solver', 'rk2', 'tspan', [0 5e3], 'dt', 0.1, 'compile_flag', 0);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor_nComps(ii, 2) = t_end / 1e3 / t_sim;
end

% plot benchmark 3
% Qfactor(:,3) = vectorise(BRIAN_data);
% Qfactor(:,4) = vectorise(NEURON_data);

plot(ax(3), nComps, Qfactor_nComps, '-o')
xlabel(ax(3), 'simulation time (ms)')
set(ax(3), 'XScale','log','YScale','log', 'XLim', [0 1010], 'XTick', [1e1 1e2 1e3])
ylabel(ax(3), 'speed factor')
leg = legend(ax(3), {'xolotl', 'DynaSim', 'BRIAN 2', 'NEURON'}, 'Location', 'EastOutside');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Post-Processing
% prettify and position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
