% show that the integration method is stable over increasing time step
% creates a supplementary figure that shows the stability of
% a model with varied maximal conductances over increasing time-step

% fix pseudorandom number generation
rng(26792);

% use zoidberg to view the Prinz database
z = zoidberg;
z.path_to_neuron_model_db = '~/code/prinz-database/neuron-db/neuron properties';
G = z.findNeurons('burster');
% generate 10 models from the database
nModels = 10;
params = G(:, randi(length(G), nModels, 1));
conds = {'NaV', 'CaT', 'CaS', 'ACurrent', 'KCa', 'Kd', 'HCurrent', 'Leak'};

% create the xolotl model
x = xolotl;
x.add('compartment', 'AB', 'A', 0.0628, 'phi', 90, 'vol', 0.0628);

x.AB.add('prinz/NaV', 'gbar', params(1, 1), 'E', 50);
x.AB.add('prinz/CaT', 'gbar', params(2, 1), 'E', 30);
x.AB.add('prinz/CaS', 'gbar', params(3, 1), 'E', 30);
x.AB.add('prinz/ACurrent', 'gbar', params(4, 1), 'E', -80);
x.AB.add('prinz/KCa', 'gbar', params(5, 1), 'E', -80);
x.AB.add('prinz/Kd', 'gbar', params(6, 1), 'E', -80);
x.AB.add('prinz/HCurrent', 'gbar', params(7, 1), 'E', -20);
x.AB.add('Leak', 'gbar', params(8, 1), 'E', -50);
x.t_end = 30e3;
x.dt = 1;

% test run
x.integrate;

% for each set of conductances,  simulate the model
% over a series of time-steps

% make a vector of dt to vary
max_dt = 1e3;
K = 1:max_dt;
all_dt = K(rem(max_dt,K) == 0);
all_dt = all_dt/1e3;

% vector to store the voltage traces
all_V = NaN(ceil(x.t_end/x.dt),length(all_dt));

% error matrix
matrix_error = NaN(length(all_dt), length(nModels));
% burst metrics matrices
burst_freq = NaN(length(all_dt), length(nModels));
duty_cycle = NaN(length(all_dt), length(nModels));
n_spikes_b = NaN(length(all_dt), length(nModels));

% hash & cache
h0 = GetMD5(all_dt);
[~, h1] = x.md5hash;
h2 = GetMD5(params);
h = GetMD5([h0,h1,h2]);

if isempty(cache(h))

  for model = 1:size(params, 2)
    textbar(model, size(params, 2))
    % set up the xolotl object with the new conductances
    for qq = 1:length(conds)
      x.AB.(conds{qq}).gbar = params(qq, model);
    end
    % run through the benchmark test over increasing dt
  	for i = length(all_dt):-1:1
      % set up the new time step
  		x.sim_dt = all_dt(i);
  		x.dt = 1;
      % run the simulation
  		[all_V(:,i), Ca] = x.integrate;
      % acquire burst metrics
      burst_metrics = psychopomp.findBurstMetrics(all_V(:, i), Ca);
      burst_freq(i, model) = 1 / (burst_metrics(1) * 1e-3);
      n_spikes_b(i, model) = burst_metrics(2);
      duty_cycle(i, model) = burst_metrics(9);
  	end
    % acquire the spike times
    for i = length(all_dt):-1:1
    	all_f(i) = xolotl.findNSpikes(all_V(:,i), -20);
    	all_f(i) = all_f(i)/(x.t_end*1e-3);
    end
    % measure the errors using the LeMasson matrix
    [M0, V_lim, dV_lim] = xolotl.V2matrix(all_V(:,1));
    for i = length(all_dt):-1:2
    	M = xolotl.V2matrix(all_V(:,i), V_lim, dV_lim);
    	matrix_error(i, model) = xolotl.matrixCost(M0,M);
    end
  end
    Q = matrix_error;
    metrics = matrix_metrics
    % cache the results for next time
    cache(h, Q, burst_freq, n_spikes_b, duty_cycle);
  else
    disp('pulling data from cache...')
    [Q, burst_freq, n_spikes_b, duty_cycle] = cache(h);
end

% generate a figure
c = lines(10);
model = 1;

% set up the simulations for the insets
for qq = 1:length(conds)
  x.AB.(conds{qq}).gbar = params(qq, model);
end

disp('beginning high time-resolution simulation...')
x.sim_dt = all_dt(1);
x.dt = 1;
% [V1, Ca1] = x.integrate;

disp('beginning low-time-resolution simulation...')
x.sim_dt = all_dt(end);
x.dt = 1;
[V2, Ca2] = x.integrate;

t = x.dt / 1e3 * (1:length(V2)); % s
[V1] = rand(length(t),1);

disp('generating figure...')
% Place axes at (0.1,0.1) with width and height of 0.8
fig = figure('outerposition',[100 100 1550 666],'PaperUnits','points','PaperSize',[1000 1000]);
ax(1) = subplot(1,2,1); hold on

% Main plot
for ii = 1:size(Q, 2)
  plot(ax(1), all_dt, Q(:, ii), '-o', 'Color', c(ii, :));
end
xlabel(ax(1), '\Deltat (ms)')
ylabel(ax(1), 'Simulation error (\epsilon_{HH})')
set(ax(1), 'box', 'off', 'XScale', 'log', 'YLim', [-1e-3, 15e-3]);

% Place second set of axes on same plot
ax(2) = axes('position', [0.2 0.6 0.1 0.1]);
plot(t, V1, 'Color', c(model, :), 'LineWidth', 1);
% xlabel(ax(2), 'Time (s)');
% ylabel(ax(2), 'V_m (mV)');
set(ax(2), 'box', 'off', 'XLim', [10 15], 'XTick', [], 'YTick', []);

% Add another set of axes
ax(3) = axes('position', [0.32 0.6 0.1 0.1]);
plot(ax(3), t, V2, 'Color', c(model, :), 'LineWidth', 1);
% xlabel(ax(3), 'Time (s)');
% ylabel(ax(3), 'V_m (mV)');
set(ax(3), 'box', 'off', 'XLim', [10 15], 'XTick', [], 'YTick', []);

% ancillary plots showing burst frequency, duty cycle, and number of spikes per burst
% burst frequency
ax(4) = subplot(3, 2, 2); hold on;
for ii = 1:size(burst_freq, 2)
  plot(ax(4), all_dt, burst_freq(:, ii), '-o', 'Color', c(ii, :));
end
xlabel(ax(4), '\Deltat (ms)')
ylabel(ax(4), 'Burst Frequency (Hz)')
set(ax(4), 'box', 'off', 'XScale', 'log', 'YLim', [-1e-3, 15e-3]);
% number of spikes per burst
ax(5) = subplot(3, 2, 4); hold on;
for ii = 1:size(n_spikes_b, 2)
  plot(ax(5), all_dt, n_spikes_b(:, ii), '-o', 'Color', c(ii, :));
end
xlabel(ax(5), '\Deltat (ms)')
ylabel(ax(5), 'Burst Frequency (Hz)')
set(ax(5), 'box', 'off', 'XScale', 'log', 'YLim', [-1e-3, 15e-3]);
% duty cycle
ax(6) = subplot(3, 2, 6); hold on;;
for ii = 1:size(duty_cycle, 2)
  plot(ax(6), all_dt, duty_cycle(:, ii), '-o', 'Color', c(ii, :));
end
xlabel(ax(6), '\Deltat (ms)')
ylabel(ax(6), 'Burst Frequency (Hz)')
set(ax(6), 'box', 'off', 'XScale', 'log', 'YLim', [-1e-3, 15e-3]);

% post-processing
prettyFig()
% deintersectAxes(ax(1:3))
