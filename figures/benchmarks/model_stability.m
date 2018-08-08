% show that the integration method is stable over increasing time step
% creates a supplementary figure that shows the stability of
% a model with varied maximal conductances over increasing time-step

% fix pseudorandom number generation
prng = 698567;
rng(prng);

% use zoidberg to view the Prinz database
z = zoidberg;
z.path_to_neuron_model_db = '~/code/prinz-database/neuron-db/neuron properties';
G = z.findNeurons('burster');
% generate 50 models from the database
conds = {'NaV', 'CaT', 'CaS', 'ACurrent', 'KCa', 'Kd', 'HCurrent', 'Leak'};

% create the xolotl model
x = xolotl;
x.add('compartment', 'AB', 'A', 0.0628,'vol', 0.0628);
x.AB.add('CalciumMech1');
x.AB.add('prinz/NaV', 'gbar', G(1,1), 'E', 50);
x.AB.add('prinz/CaT', 'gbar', G(1,2), 'E', 30);
x.AB.add('prinz/CaS', 'gbar', G(1,3), 'E', 30);
x.AB.add('prinz/ACurrent', 'gbar', G(1,4), 'E', -80);
x.AB.add('prinz/KCa', 'gbar', G(1,5), 'E', -80);
x.AB.add('prinz/Kd', 'gbar', G(1,6), 'E', -80);
x.AB.add('prinz/HCurrent', 'gbar', G(1,7), 'E', -20);
x.AB.add('Leak', 'gbar', G(1,8), 'E', -50);
x.t_end = 20e3;
x.sim_dt = 0.1;
x.dt = 1;

% check to make sure that they are actually bursting
disp('checking models for bursting...')

if isempty(cache(['checkingmodelsforbursting']))
  disp('running bursting tests...')
  passingModels = [];
  % set up the conductances
  while length(passingModels) <= 20
    model = randi(length(G),1);
    params = G(:, model);
    for qq = 1:length(conds)
      x.AB.(conds{qq}).gbar = params(qq);
    end
    % simulate each model
    [V, Ca] = x.integrate;
    V = V(10e3/x.dt:end);
    Ca = Ca(10e3/x.dt:end,1);
    burst_metrics = psychopomp.findBurstMetrics(V, Ca);
    burst_freq = 1 / (burst_metrics(1) * 1e-3);
    % confirm that burst frequency is in [0.5, 2.0]
    if burst_freq >= 0.5 & burst_freq <= 2.0 & burst_metrics(10) == 0 & burst_metrics(9) >= 0.2 & burst_metrics(2) >= 3
      passingModels(end+1) = model;
    end
  end
  cache('checkingmodelsforbursting', passingModels);
else
  passingModels = cache('checkingmodelsforbursting');
end

% remove all non-passing models
params = G(:, passingModels);
disp([num2str(size(params,2)) ' models remaining'])

% for each set of conductances, simulate the model
% over a series of time-steps

% make a vector of dt to vary
max_dt = 1e3;
K = 1:max_dt;
all_dt = K(rem(max_dt,K) == 0);
all_dt = all_dt/1e3;

% vector to store the voltage traces
all_V = NaN(ceil(x.t_end/x.dt),length(all_dt));

% burst metrics matrices
burst_freq = NaN(length(all_dt), length(size(params, 2)));
duty_cycle = NaN(length(all_dt), length(size(params, 2)));
n_spikes_b = NaN(length(all_dt), length(size(params, 2)));

% hash & cache

if isempty(cache('simulatingmodels'))
  disp('simulating...')
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
  		[V, Ca] = x.integrate;
      V = V(10e3/x.dt:end);
      Ca = Ca(10e3/x.dt:end,1);
      % acquire burst metrics
      burst_metrics = psychopomp.findBurstMetrics(V, Ca);
      burst_freq(i, model) = 1 / (burst_metrics(1) * 1e-3);
      n_spikes_b(i, model) = burst_metrics(2);
      duty_cycle(i, model) = burst_metrics(9);
  	end
  end
    % cache the results for next time
    cache('simulatingmodels', burst_freq, n_spikes_b, duty_cycle);
else
    disp('pulling data from cache...')
    [burst_freq, duty_cycle, n_spikes_b] = cache('simulatingmodels');
end

% get rid of any models which aren't bursting at low time step
modelIndex = passingModels;
passingModels = burst_freq(1,:) > 0 & all(n_spikes_b <= 10);
burst_freq = burst_freq(:, passingModels);
duty_cycle = duty_cycle(:, passingModels);
n_spikes_b = n_spikes_b(:, passingModels);
% if a model stops bursting, don't plot anything
burst_freq(burst_freq <= 0) = NaN;
duty_cycle(duty_cycle <= 0) = NaN;
n_spikes_b(n_spikes_b <= 0) = NaN;

% simulate against canonical traces (using ode23t)
% parameters to simulate (getting rid of all overridden models)
params = params(:, passingModels);
params_mScm2 = params / 10.0; % mS/cm^2
sol = struct('t', [], 'v', [], 'ca', []);

if ~exist('neuron_standalone_solutions.mat', 'file')
  disp('simulating canonical traces...')
  for model = 1:size(params, 2)
    textbar(model, size(params, 2))
    [t, n] = ode23t(@(t, x) neuron_standalone(t, x, params_mScm2(:, model)), [0 20], [0 0 0 0 0 0 0 1 1 1 1 -65 0.05]);
    sol(model).t = t;
    sol(model).v = n(:, 12);
    sol(model).ca = n(:, 13);
  end
  save('neuron_standalone_solutions.mat', 'sol')
else
  disp('loading canonical traces...')
  load('neuron_standalone_solutions.mat')
end

% interpolate/downsample to dt = 1 ms
nV   = NaN(20e3, length(sol));
nCa  = NaN(20e3, length(sol));
for model = 1:length(sol)
  nV(:, model) = interp1(sol(model).t, sol(model).v, 1e-3:1e-3:20);
  nCa(:, model) = interp1(sol(model).t, sol(model).ca, 1e-3:1e-3:20);
end

% remove transient
nV = nV(10e3/x.dt:end,:);
nCa = nCa(10e3/x.dt:end,:);

% acquire burst metrics for downsampled canonical traces
canonical_burst_freq = NaN(length(sol), 1);
canonical_duty_cycle = NaN(length(sol), 1);
canonical_n_spikes_b = NaN(length(sol), 1);

for model = 1:length(sol)
  burst_metrics = psychopomp.findBurstMetrics(nV(:, model), nCa(:, model), Inf, Inf);
  canonical_burst_freq(model) = 1 / (burst_metrics(1) * 1e-3);
  canonical_duty_cycle(model) = burst_metrics(9);
  canonical_n_spikes_b(model) = burst_metrics(2);
end
canonical_burst_freq(canonical_burst_freq<0) = NaN;
canonical_duty_cycle(canonical_duty_cycle<0) = NaN;
canonical_n_spikes_b(canonical_n_spikes_b<0) = NaN;

% simulate xolotl traces at low time-resolution
disp('simulating xolotl traces...')
xV   = NaN(20e3, length(sol));
xCa  = NaN(20e3, length(sol));
x.dt = 1;
x.sim_dt = 0.05;
for model = 1:length(sol)
  % set up the xolotl object with the new conductances
  for qq = 1:length(conds)
    x.AB.(conds{qq}).gbar = params(qq, model);
  end
  % simulate and store
  [xV(:, model), Ca] = x.integrate;
  xCa(:, model) = Ca(:, 1);
end

% remove transient
xV = xV(10e3/x.dt:end,:);
xCa = xCa(10e3/x.dt:end,:);

% generate a figure
c = lines(size(burst_freq, 2));

disp('generating figure...')
fig = figure('outerposition',[100 100 1550 666],'PaperUnits','points','PaperSize',[1000 1000]);

% generate axes
for ii = 1:3
  counter = 2*ii - 1;
  ax(ii) = subplot(3, 2, counter); hold on
end
ax(4) = subplot(3, 4, 3); hold on;
ax(5) = subplot(3, 4, 4); hold on;
ax(6) = subplot(3, 2, [4 6]); hold on;

% burst frequency
for ii = 1:size(burst_freq, 2)
  plot(ax(1), all_dt, burst_freq(:, ii) / canonical_burst_freq(ii), '-o', 'Color', c(ii, :));
end
ylabel(ax(1), 'Norm. Burst Frequency')
set(ax(1), 'box', 'off', 'XScale', 'log', 'YScale', 'log');

% number of spikes per burst
for ii = 1:size(n_spikes_b, 2)
  plot(ax(2), all_dt, n_spikes_b(:, ii) / canonical_n_spikes_b(ii), '-o', 'Color', c(ii, :));
end
ylabel(ax(2), 'Norm. Spikes/Burst')
set(ax(2), 'box', 'off', 'XScale', 'log', 'YScale', 'log');

% duty cycle
for ii = 1:size(duty_cycle, 2)
  plot(ax(3), all_dt, duty_cycle(:, ii) / canonical_duty_cycle(ii), '-o', 'Color', c(ii, :));
end
xlabel(ax(3), '\Deltat (ms)')
ylabel(ax(3), 'Norm. Duty Cycle')
set(ax(3), 'box', 'off', 'XScale', 'log', 'YScale', 'log');

% plot snippet of the voltage traces
% look at the second burst of the first model

[~, spike_times, Ca_peaks] = psychopomp.findBurstMetrics(xV(:,1),xCa(:,1));
burstStart = Ca_peaks(2);
xStart = spike_times(find(diff(spike_times) > 500, 1)+1);
[~, spike_times, Ca_peaks] = psychopomp.findBurstMetrics(nV(:,1),nCa(:,1));
nStart = spike_times(find(diff(spike_times) > 500, 1)+1);

time = x.dt * (1:500);
plot(ax(4), time, nV(nStart-200:nStart+300-1,1), 'LineWidth', 1, 'Color', [c(1, :) 1.0]);
plot(ax(4), time, xV(xStart-200:xStart+300-1,1), 'LineWidth', 1, 'Color', [c(1, :) 0.5]);
xlabel(ax(4), 'Time (ms)');
ylabel(ax(4), 'V_m (mV)');
legend(ax(4), {'ode23t', 'exp. Euler'});

% scatter plot of metrics between exp. euler and ode23t
c2 = parula(16);
for model = 1:size(burst_freq, 2)
  scatter(ax(6), repmat(canonical_burst_freq(model), size(burst_freq, 1), 1), burst_freq(:, model), 24, c2);
end
plot(ax(6), 0:3, 0:3, 'k:');
xlabel(ax(6), 'ode23t Burst Frequency (Hz)')
ylabel(ax(6), 'Exp. Euler Burst Frequency');
colorbar

% post-processing
prettyFig()
labelAxes(ax(1),'A','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(2),'B','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(3),'C','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(4),'D','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(5),'E','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(6),'F','x_offset',-.05,'y_offset',-.025,'font_size',18);

% deintersectAxes(ax(1:6))
