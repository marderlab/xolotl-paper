% make sure that you are in the correct directory
% cd('~/code/simulation-environment-paper/neuron/')

% compile NEURON
system('nrnivmodl na.mod kd.mod')

% run the benchmark tests
if ~exist('neuron_benchmark1.csv')
  system('nrniv -python benchmark1.py')
elseif ~exist('neuron_benchmark2.csv')
  system('nrniv -python benchmark2.py')
elseif ~exist('neuron_benchmark3.csv')
  system('nrniv -python benchmark3.py')
end

% plot the benchmarks
figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]);

benchmark1 = csvread('neuron_benchmark1.csv');
benchmark2 = csvread('neuron_benchmark2.csv');
benchmark3 = csvread('neuron_benchmark3.csv');


% benchmark 1
max_dt      = 1000;
K           = 1:max_dt;
dt          = K(rem(max_dt,K) == 0);
dt          = dt/1e3;

ax(1) = subplot(1,3,1);
plot(ax(1), dt, benchmark1, '-o')
xlabel(ax(1), 'time step (ms)')
ylabel(ax(1), 'sim time / real time')

% benchmark 2
t_end   = round(logspace(1,6,20)); % ms

ax(2) = subplot(1,3,2);
plot(ax(2), t_end, benchmark2, '-o')
xlabel(ax(2), 'simulation time (ms)')
% ylabel(ax(2), 'sim time / real time')

% benchmark 3
nComps    = [1, 2, 4, 8, 16, 32, 64, 128 250 500 1000];

ax(3) = subplot(1,3,3);
plot(ax(3), nComps, benchmark3, '-o')
xlabel(ax(3), '# of compartments')
% ylabel(ax(3), 'sim time / real time')

% post-processing
set(ax, 'XScale', 'log', 'YLim', [0 20])
prettyFig()

for ii = 1:3
  box(ax(ii), 'off')
end
