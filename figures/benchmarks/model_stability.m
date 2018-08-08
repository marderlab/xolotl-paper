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
x.t_end = 10e3;
x.sim_dt = 0.1;
x.dt = 1;

% check to make sure that they are actually bursting
disp('checking models for bursting...')

if isempty(cache(['checkingmodelsforbursting']))
  disp('running bursting tests...')
  passingModels = [];
  % set up the conductances
  while length(passingModels) <= 50
    model = randi(length(G),1);
    params = G(:, model);
    for qq = 1:length(conds)
      x.AB.(conds{qq}).gbar = params(qq);
    end
    % simulate each model
    [V, Ca] = x.integrate;
    burst_metrics = psychopomp.findBurstMetrics(V, Ca(:, 1));
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
h0 = GetMD5(all_dt);
[~, h1] = x.md5hash;
h2 = GetMD5(params);
h = GetMD5([h0,h1,h2]);

if isempty(cache(h))
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
  		[all_V(:,i), Ca] = x.integrate;
      % acquire burst metrics
      burst_metrics = psychopomp.findBurstMetrics(all_V(:, i), Ca(:, 1));
      burst_freq(i, model) = 1 / (burst_metrics(1) * 1e-3);
      n_spikes_b(i, model) = burst_metrics(2);
      duty_cycle(i, model) = burst_metrics(9);
  	end
  end
    % cache the results for next time
    cache(h, burst_freq, n_spikes_b, duty_cycle);
else
    disp('pulling data from cache...')
    [burst_freq, duty_cycle, n_spikes_b] = cache(h);
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

% generate a figure
c = lines(size(burst_freq, 2));

disp('generating figure...')
% Place axes at (0.1,0.1) with width and height of 0.8
fig = figure('outerposition',[100 100 1550 666],'PaperUnits','points','PaperSize',[1000 1000]);

% generate axes
for ii = 1:6
  ax(ii) = subplot(3, 2, ii); hold on
end

% burst frequency
for ii = 1:size(burst_freq, 2)
  plot(ax(1), all_dt, burst_freq(:, ii), '-o', 'Color', c(ii, :));
end
ylabel(ax(1), 'Burst Frequency (Hz)')
set(ax(1), 'box', 'off', 'XScale', 'log', 'YLim', [0.5, 2.0]);

% number of spikes per burst
for ii = 1:size(n_spikes_b, 2)
  plot(ax(3), all_dt, n_spikes_b(:, ii), '-o', 'Color', c(ii, :));
end
ylabel(ax(3), 'Spikes/Burst')
set(ax(3), 'box', 'off', 'XScale', 'log', 'YLim', [0, 1.2*max(vectorise(n_spikes_b))]);

% duty cycle
for ii = 1:size(duty_cycle, 2)
  plot(ax(5), all_dt, duty_cycle(:, ii), '-o', 'Color', c(ii, :));
end
xlabel(ax(5), '\Deltat (ms)')
ylabel(ax(5), 'Duty Cycle')
set(ax(5), 'box', 'off', 'XScale', 'log', 'YLim', [0, 1.0]);

% burst frequency (normalized)
for ii = 1:size(burst_freq, 2)
  plot((ax(2)), all_dt, burst_freq(:, ii) ./ burst_freq(1,ii), '-o', 'Color', c(ii, :));
end
ylabel(ax(2), 'Norm. Burst Frequency')
set((ax(2)), 'box', 'off', 'XScale', 'log', 'YScale', 'log');

% number of spikes per burst (normalized)
for ii = 1:size(n_spikes_b, 2)
  plot(ax(4), all_dt, n_spikes_b(:, ii) ./ n_spikes_b(1,ii), '-o', 'Color', c(ii, :));
end
ylabel(ax(4), 'Norm. Spikes/Burst')
set(ax(4), 'box', 'off', 'XScale', 'log', 'YScale', 'log');

% duty cycle (normalized)
for ii = 1:size(duty_cycle, 2)
  plot(ax(6), all_dt, duty_cycle(:, ii) ./ duty_cycle(1,ii), '-o', 'Color', c(ii, :));
end
ylabel(ax(6), 'Norm. Duty Cycle')
xlabel(ax(6), '\Deltat (ms)')
set(ax(6), 'box', 'off', 'XScale', 'log', 'YScale', 'log');

% post-processing
prettyFig()
labelAxes(ax(1),'A','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(2),'B','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(3),'C','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(4),'D','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(5),'E','x_offset',-.05,'y_offset',-.025,'font_size',18);
labelAxes(ax(6),'F','x_offset',-.05,'y_offset',-.025,'font_size',18);

deintersectAxes(ax(1:6))

%% NEURON STANDALONE
