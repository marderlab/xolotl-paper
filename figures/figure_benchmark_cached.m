%% reproduces Benchmark figure using saved data

load('~/code/simulation-environment-paper/cache_benchmark.mat')

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


% get downsampling time
time        = dt(end) * (1:(t_end / max(dt)));

% if the coincidence factor is greater than 1, it is the same as 0
accuracy(accuracy >= 1) = 0;
accuracy(accuracy == 0) = NaN;

% plot benchmark 1
for ii = 1:3
  plot(ax(1), dt, Qfactor_acc(:,ii), '-o', 'Color', c(ii, :), 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :));
end
% xlabel(ax(1), 'time step (ms)')
ylabel(ax(1), 'speed factor')
set(ax(1), 'XScale', 'log', 'YScale', 'log', 'XLim', [1e-3 1.1], 'XTick', [1e-3 1e-2 1e-1 1e0], 'YTick', [1e0 1e1 1e2])

for ii = 1:3
  plot(ax(2), dt, accuracy(:,ii), '-o', 'Color', c(ii, :), 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :));
end
xlabel(ax(2), 'time step (ms)')
ylabel(ax(2), 'coincidence factor')
set(ax(2), 'XScale', 'log', 'YLim', [0 1], 'XTick', [1e-3 1e-2 1e-1 1e0], 'XLim', [1e-3 1.1])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Benchmark Test #2
% simulate a hodgkin-huxley model neuron over a series of simulation times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% useful constants
dt = 0.1; % ms

t_end   = round(logspace(1,6,20)); % ms

% set up simulation parameters for xolotl
x.sim_dt = dt; % ms
x.dt    = dt; % ms

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

% plot benchmark 3

for ii = 1:3
  plot(ax(4), nComps, Qfactor_nComps(:,ii), '-o', 'Color', c(ii, :), 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :));
end
xlabel(ax(4), 'number of compartments')
ylabel(ax(4), 'speed factor')
set(ax(4), 'XScale', 'log', 'YScale', 'log', 'XLim', [0 1010], 'XTick', [1e0 1e1 1e2 1e3])
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
  0.0691    0.6358    0.2129    0.2638;
  0.0716    0.2576    0.2129    0.2638;
  0.3650    0.2576    0.2129    0.6617;
  0.6608    0.2576    0.2129    0.6617];

for ii = 1:length(ax)
  ax(ii).Position = pos(ii, :);
end

% label the subplots
% labelFigure('capitalise', true)

% break the axes
deintersectAxes(ax(1:4))
