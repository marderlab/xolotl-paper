%% Figure 7: Benchmarking Xolotl against DynaSim and NEURON

% create figure
fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;

% speed versus time-step
ax(1) = subplot(2,3,1); hold on
ax(1).Tag = 'Q vs. dt';
% accuracy versus time-step
ax(2) = subplot(2,3,4); hold on
ax(2).Tag = 'C vs. dt';
% speed versus network size
ax(3) = subplot(1,3,2); hold on
ax(3).Tag = 'Q vs. t_end';
% accuracy vs. dt
ax(4) = subplot(1,3,3); hold on
ax(4).Tag = 'Q vs. nComps';

% set up xolotl object
x = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);

% set up DynaSim equation block
equations = { ...
  'gNa = 1000; gKd = 300; gLeak = 1; Cm = 10', ...
  'INa(v,m,h)=gNa.*m.^3.*h.*(v-50)',...
  'IKd(v,n)=gKd.*n.^4.*(v+80)',...
  'ILeak(v)=gLeak.*(v+50)',...
  'dv/dt=(0.2./0.01-INa(v,m,h)-IKd(v,n)-ILeak(v))./Cm;',...
  'v(0)=-65;m(0)=0;n(0)=0;h(0)=1',...
  'dm/dt=(minf(v)-m)./taum(v)',...
  'dh/dt=(hinf(v)-h)./tauh(v)',...
  'dn/dt=(ninf(v)-n)./taun(v)',...
  'minf(v)=1.0./(1.0+exp((v+25.5)./-5.29))',...
  'hinf(v)=1.0./(1.0+exp((v+48.9)./5.18))',...
  'ninf(v)=1.0./(1.0+exp((v+12.3)./-11.8))',...
  'taum(v)=1.32-1.26./(1+exp((v+120.0)./-25.0))',...
  'tauh(v)=(0.67./(1.0+exp((v+62.9)./-10.0))).*(1.5+1.0./(1.0+exp((v+34.9)./3.6)))',...
  'taun(v)=7.2-6.4./(1.0+exp((v+28.3)./-19.2))'};

% useful constants
t_end       = 5e3;
x.t_end     = t_end; % ms
c           = lines(3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Benchmark Test #1
% simulate a hodgkin-huxley model neuron over a series of time-steps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up time-step
max_dt      = 1000;
K           = 1:max_dt;
dt          = K(rem(max_dt,K) == 0);
dt          = dt/1e3;

Qfactor_acc = NaN(length(dt), 3);
accuracy    = NaN(length(dt), 3);

% get downsampling time
time        = dt(end) * (1:(t_end / max(dt)));

% get canonical trace
x.sim_dt    = dt(1);
x.dt        = dt(1);
tic;
V0          = x.integrate(0.2);
V0          = interp1(dt(1)*(1:length(V0)), V0, time);
Qfactor_acc(1) = toc; % s

% acquire first 1000 spikes with threshold at 0 mV
canonSpikes = zeros(length(V0), 1);
canonSpikes(nonnans(psychopomp.findNSpikes(V0, 1000, 0))) = 1;

% test xolotl

for ii = 1:length(dt)
  textbar(ii, length(dt))
  x.sim_dt  = dt(ii);
  x.dt      = dt(ii);
  tic;
  V = x.integrate(0.2);
  Qfactor_acc(ii,1) = toc;
  V = interp1(x.dt*(1:length(V)), V, time);
  modelSpikes = zeros(length(V), 1);
  modelSpikes(nonnans(psychopomp.findNSpikes(V, 1000, 0))) = 1;
  accuracy(ii,1) = coincidence(canonSpikes, modelSpikes, max(dt), 1);
end

% test DynaSim
for ii = 1:length(dt)
  textbar(ii, length(dt))
  tic;
  data = dsSimulate(equations, 'solver', 'rk2', 'tspan', [dt(ii) t_end], 'dt', dt(ii), 'compile_flag', 1);
  Qfactor_acc(ii,2) = toc;
  V = interp1(dt(ii)*(1:length(data.(data.labels{1}))), data.(data.labels{1}), time);
  modelSpikes = zeros(length(V), 1);
  modelSpikes(nonnans(psychopomp.findNSpikes(V, 1000, 0))) = 1;
  accuracy(ii,2) = coincidence(canonSpikes, modelSpikes, max(dt), 1);
end

% process the speed factor
Qfactor_acc = x.t_end / 1e3 ./ Qfactor_acc; % unitless

% test NEURON

% indexed from t = 0, need to eliminate first time point
NEURON_data   = csvread('~/code/simulation-environment-paper/neuron/neuron_benchmark1.csv');
NEURON_raw    = csvread('~/code/simulation-environment-paper/neuron/neuron_benchmark1_raw.csv');

for ii = 1:length(dt)
  try
    Qfactor_acc(ii, 3) = NEURON_data(ii);
    V = interp1(dt(ii)*(1:length(nonnans(NEURON_raw(2:end,ii)))), nonnans(NEURON_raw(2:end,ii)), time);
    modelSpikes = zeros(length(V), 1);
    modelSpikes(nonnans(psychopomp.findNSpikes(V, 1000, 0))) = 1;
    accuracy(ii,3) = coincidence(canonSpikes, modelSpikes, max(dt), 1);
  catch
    Qfactor_acc(ii,3) = NaN;
    accuracy(ii,3) = NaN;
  end
end


% plot benchmark 1
for ii = 1:3
  plot(ax(1), dt, Qfactor_acc(:,ii), '-o', 'Color', c(ii, :), 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :));
end
% xlabel(ax(1), 'time step (ms)')
ylabel(ax(1), 'speed factor')
set(ax(1), 'XScale', 'log', 'YScale', 'log', 'XLim', [0 1.01])

for ii = 1:3
  plot(ax(2), dt, accuracy(:,ii), '-s', 'Color', c(ii, :), 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :));
end
xlabel(ax(2), 'time step (ms)')
ylabel(ax(2), 'coincidence factor')
set(ax(2), 'XScale', 'log', 'YLim', [0 1], 'XLim', [0 1.01])
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Benchmark Test #2
% simulate a hodgkin-huxley model neuron over a series of simulation times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% useful constants
dt = 0.1; % ms

t_end   = round(logspace(1,6,20)); % ms
Qfactor = NaN(length(t_end), 3);

% test xolotl

% set up simulation parameters for xolotl
x.sim_dt = dt; % ms
x.dt    = dt; % ms

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
  data = dsSimulate(equations, 'solver', 'rk2', 'tspan', [0 t_end(ii)], 'dt', dt, 'compile_flag', 1);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor(ii, 2) = t_end(ii) / 1e3 / t_sim;
end

% recover benchmark for BRIAN 2
% BRIAN_data = csvread('~/code/simulation-environment-paper/brian/brian_benchmark1.csv');

% recover benchmark for NEURON
NEURON_data = csvread('~/code/simulation-environment-paper/neuron/neuron_benchmark2.csv');

% plot benchmark 2
% Qfactor(:,3) = vectorise(BRIAN_data);
Qfactor(:,3) = vectorise(NEURON_data);

for ii = 1:3
  plot(ax(3), t_end, Qfactor(:,ii), '-o', 'Color', c(ii, :), 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :));
end
xlabel(ax(3), 'simulation time (ms)')
ylabel(ax(3), 'speed factor')
set(ax(3), 'XScale', 'log', 'YScale', 'log', 'XTick', [1e0 1e1 1e3 1e5])
% leg = legend(ax(2), {'xolotl', 'DynaSim', 'BRIAN 2', 'NEURON'}, 'Location', 'EastOutside');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Benchmark Test #3
% speed test over number of compartments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up general simulation parameters
t_end     = 5e3; % ms
dt        = 0.1; % ms
nComps    = [1, 2, 4, 8, 16, 32, 64, 128 250 500 1000];% 2000 4000 10000];
Qfactor_nComps = zeros(length(nComps),3);

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
  x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
  x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
  x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
  x.HH.add('Leak', 'gbar', 1, 'E', -50);
  x.cleanup
  x.skip_hash = true;
  if nComps(ii) > 1
    x.replicate('HH', nComps(ii));
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
  S.populations.name       = 'test';
  S.populations.size       = nComps(ii);
  S.populations.equations  = equations;

  % begin timing
  tic;
  data = dsSimulate(S, 'solver', 'rk2', 'tspan', [0 t_end], 'dt', dt, 'compile_flag', 1);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor_nComps(ii, 2) = t_end / 1e3 / t_sim;
end

% recover benchmark for NEURON
NEURON_data = csvread('~/code/simulation-environment-paper/neuron/neuron_benchmark3.csv');

% plot benchmark 3
% Qfactor(:,3) = vectorise(BRIAN_data);
Qfactor_nComps(:,3) = vectorise(NEURON_data);

for ii = 1:3
  plot(ax(4), nComps, Qfactor_nComps(:,ii), '-o', 'Color', c(ii, :), 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :));
end
xlabel(ax(4), 'number of compartments')
ylabel(ax(4), 'speed factor')
set(ax(4), 'XScale', 'log', 'YScale', 'log', 'XTick', [1e0 1e1 1e2 1e3])
leg = legend(ax(4), {'xolotl', 'DynaSim', 'NEURON'}, 'Location', 'EastOutside');

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
  0.0692    0.6358    0.2129    0.2638;
  0.0717    0.2576    0.2129    0.2638;
  0.3867    0.2576    0.2129    0.6617;
  0.6825    0.2576    0.2129    0.6617];

for ii = 1:length(ax)
  ax(ii).Position = pos(ii, :);
end

% label the subplots
% labelFigure('capitalise', true)

% break the axes
deintersectAxes(ax(1:4))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Caching
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('~/code/simulation-environment-paper/cache_benchmark.mat', ...
  'Qfactor', 'Qfactor_acc', 'Qfactor_nComps', 'accuracy')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function Definitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Gamma = coincidence(canonSpikes, modelSpikes, dt, delta)
  % s the coincidence factor between two spike-trains
  % adapted from Jolivet et al. 2008

  spikeRange      = round(delta / dt);
  assert(spikeRange >= 1, 'spikeRange cannot be less than one time-step!')

  nCoincidences   = 0;
  nCanonSpikes    = sum(canonSpikes);
  nModelSpikes    = sum(modelSpikes);
  f               = nModelSpikes / length(nModelSpikes);
  mCoincidences   = 2 * f * spikeRange * nCanonSpikes;
  normalization   = 1 - 2 * f * spikeRange;

  % count the number of coincidences
  % between the canonical trace and the model trace
  for ii = 1:length(canonSpikes)-spikeRange
    if sum(modelSpikes(ii + spikeRange)) > 0 & sum(canonSpikes(ii+spikeRange)) > 0
      nCoincidences = nCoincidences + 1;
    end
  end

  numerator       = nCoincidences - mCoincidences;
  denominator     = (1/2) * (nCanonSpikes + nModelSpikes);
  Gamma           = (1/normalization) * numerator / denominator;
end
