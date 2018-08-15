% show that the integration method is stable over increasing time step
% creates a supplementary figure that shows the stability of
% a model with varied maximal conductances over increasing time-step

clearvars -except z

redo = false;

t_end = 30e3; % ms
t_transient = 10e3; % ms
dt = .1; % ms

% make a vector of dt to vary
max_dt = 1e2;
K = 1:max_dt;
all_dt = K(rem(max_dt,K) == 0);
all_dt = all_dt/1e3;

% fix pseudorandom number generation
prng = 1984;
rng(prng);

if ~exist('z','var')
	% use zoidberg to view the Prinz database
	z = zoidberg;
end

G = z.findNeurons('burster');
% generate 50 models from the database
conds = {'NaV', 'CaT', 'CaS', 'ACurrent', 'KCa', 'Kd', 'HCurrent', 'Leak'};

% create the xolotl model
x = xolotl;
x.add('compartment', 'AB', 'A', 0.0628,'vol', 0.0628);
x.AB.add('CalciumMech1');
x.AB.add('prinz/NaV', 'gbar', 1, 'E', 50);
x.AB.add('prinz/CaT', 'gbar', 1, 'E', 30);
x.AB.add('prinz/CaS', 'gbar', 1, 'E', 30);
x.AB.add('prinz/ACurrent', 'gbar', 1, 'E', -80);
x.AB.add('prinz/KCa', 'gbar', 1, 'E', -80);
x.AB.add('prinz/Kd', 'gbar', 1, 'E', -80);
x.AB.add('prinz/HCurrent', 'gbar', 1, 'E', -20);
x.AB.add('Leak', 'gbar', 1, 'E', -50);
x.t_end = t_end;
x.sim_dt = dt;
x.dt = dt;

% check to make sure that they are actually bursting
h = GetMD5([GetMD5(prng) GetMD5(G) x.hash]);
disp('checking models for bursting...')

if isempty(cache(h)) | redo

	disp('running bursting tests...')
	passingModels = [];
	% set up the conductances
	while length(passingModels) <= 10
		model = randi(length(G),1);
		params = G(:, model);
		for qq = 1:length(conds)
			x.AB.(conds{qq}).gbar = params(qq);
		end
		x.reset;
		% simulate at low time resolution
		x.sim_dt = 0.1;
		x.t_end = t_transient;
		x.integrate;

		% simulate each model
		x.t_end = t_end - t_transient;
		[V, Ca] = x.integrate;

		burst_metrics = psychopomp.findBurstMetrics(V, Ca(:,1));

		if burst_metrics(end) >  0

			disp('Crappy model')
			continue
		end



		disp('simulating at high time-resolution...')
		x.reset;
		x.sim_dt = 0.001;
		x.t_end = t_end - t_transient;

		% simulate each model
		[V, Ca] = x.integrate;

		burst_metrics = psychopomp.findBurstMetrics(V, Ca(:,1));

		if burst_metrics(end) >  0
			disp('Crappy model')
			continue
		end

		passingModels(end+1) = model;

		disp([num2str(length(passingModels)) ' passing models...'])


	end
	cache(h, passingModels);
else
	passingModels = cache(h);
end



% remove all non-passing models
params = G(:, passingModels);


% now solve these models using a ODE solver



% simulate against canonical traces (using ode23t)
params = params(:, 1:length(passingModels));
V_exact = NaN(t_end*10,length(passingModels));
Ca_exact = NaN(t_end*10,length(passingModels));
time = (1:length(V_exact))*1e-4;

h = GetMD5([GetMD5(params) x.hash]);
if isempty(cache(h)) | redo | true
	disp('simulating canonical traces...')
	for model = 1:size(params, 2)
		textbar(model, size(params, 2))
		[t, n] = ode23t(@(t, x) neuron_standalone(t, x, params(:, model)), [0 t_end/1e3], [0 0 0 0 0 0 0 1 1 1 1 -60 0.05*10^(-3)]);

		% redo it with a better tolerance
		keyboard



		 V_exact(:,model) = interp1(t, n(:,12), time);
		 Ca_exact(:,model) = interp1(t, n(:,13), time);

	end
	cache(h, Ca_exact, V_exact)
else
	disp('loading canonical traces...')
	[Ca_exact, V_exact] = cache(h);
end





% show one example trace 
show_this = 11;

figure('outerposition',[300 300 1200 1100],'PaperUnits','points','PaperSize',[1200 1100]); hold on

subplot(3,2,1); hold on
plot(time,V_exact(:,show_this),'k')
set(gca,'XLim',[0 2])
xlabel('Time (s)')
ylabel('V_m (mv)')

subplot(3,2,[2 4]); hold on
dV = [NaN; diff(V_exact(:,show_this))];
plot(V_exact(1:2e4,show_this),10*dV(1:2e4),'k.');
xlabel('V_m (mV)')
ylabel('dV_m (mV/ms)')

% now use xolotl to integrate this model
for qq = 1:length(conds)
	x.AB.(conds{qq}).gbar = params(qq,show_this);
end

x.reset;
x.sim_dt = .01;
x.t_end = 3e3;
x.dt = .1;
V = x.integrate;

subplot(3,2,3);
t = (1:length(V))*x.dt*1e-3;
plot(t,V,'r')
set(gca,'XLim',[0 2])
xlabel('Time (s)')
ylabel('V_m (mv)')

subplot(3,2,[2 4]);
dV = [NaN; diff(V)];
plot(V(1:2e4),10*dV(1:2e4),'r.');



% vector to store the voltage traces
all_V = NaN(ceil(x.t_end/x.dt),length(all_dt));

% burst metrics matrices
burst_freq = NaN(length(all_dt), length(size(params, 2)));
duty_cycle = NaN(length(all_dt), length(size(params, 2)));
n_spikes_b = NaN(length(all_dt), length(size(params, 2)));

% simulate the model using xolotl at various time-steps
h = GetMD5([x.hash passingModels]);


% compute LeMasson matrices using the canonical traces


return


if isempty(cache(h)) | redo 

	disp('simulating xolotl models at different time steps...')
	for model = 1:size(params, 2)
		textbar(model, size(params, 2))

		% set up the xolotl object with the new conductances
		% can't use x.set because Prinz doesn't use
		% alphabetical ordering
		for qq = 1:length(conds)
			x.AB.(conds{qq}).gbar = params(qq, model);
		end

		% run through the benchmark test over increasing dt

		for i = length(all_dt):-1:1

			x.reset;

			% go through a transient quickly
			x.sim_dt = .1;
			x.t_end = t_transient;
			x.integrate;

			% set up the new time step
			x.sim_dt = all_dt(i);
			x.dt = dt;
			x.t_end = t_end;		

			[V, Ca] = x.integrate;

			% acquire burst metrics
			burst_metrics = psychopomp.findBurstMetrics(V, Ca(:,1));
			burst_freq(i, model) = 1 / (burst_metrics(1) * x.dt*1e-3);
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

return

% if a model stops bursting, don't plot anything
burst_freq(burst_freq <= 0) = NaN;
duty_cycle(duty_cycle <= 0) = NaN;
n_spikes_b(n_spikes_b <= 0) = NaN;



% acquire burst metrics for downsampled canonical traces
canonical_burst_freq = NaN(size(V_exact,2), 1);
canonical_duty_cycle = NaN(size(V_exact,2), 1);
canonical_n_spikes_b = NaN(size(V_exact,2), 1);

for model = 1:size(V_exact,2)
	burst_metrics = psychopomp.findBurstMetrics(V_exact((t_transient/dt):end,model), Ca_exact((t_transient/dt):end,model), Inf, Inf);
	canonical_burst_freq(model) = 1 / (burst_metrics(1) * 1e-3*x.dt);
	canonical_duty_cycle(model) = burst_metrics(9);
	canonical_n_spikes_b(model) = burst_metrics(2);
end


