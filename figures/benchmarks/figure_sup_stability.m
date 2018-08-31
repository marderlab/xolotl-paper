% show that the integration method is stable over increasing time step
% creates a supplementary figure that shows the stability of
% a model with varied maximal conductances over increasing time-step

clearvars -except z


show_tol = logspace(-5,-2,5);
n_tol = 10;

redo = false;

t_end = 30e3; % ms
t_transient = 10e3; % ms
dt = .1; % ms


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


% and another one using rk4 solvers 
vol = 0.0628; % this can be anything, doesn't matter
f = 14.96; % uM/nA
tau_Ca = 200;
F = 96485.3329; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;

x2 = xolotl;
x2.add('rk4/compartment', 'AB', 'A', 0.0628,'vol', 0.0628);
x2.AB.add('CalciumMech4','phi',phi);
x2.AB.add('prinz/rk4/NaV', 'gbar', 1, 'E', 50);
x2.AB.add('prinz/rk4/CaT', 'gbar', 1, 'E', 30);
x2.AB.add('prinz/rk4/CaS', 'gbar', 1, 'E', 30);
x2.AB.add('prinz/rk4/ACurrent', 'gbar', 1, 'E', -80);
x2.AB.add('prinz/rk4/KCa', 'gbar', 1, 'E', -80);
x2.AB.add('prinz/rk4/Kd', 'gbar', 1, 'E', -80);
x2.AB.add('prinz/rk4/HCurrent', 'gbar', 1, 'E', -20);
x2.AB.add('Leak', 'gbar', 1, 'E', -50);
x2.t_end = t_end;
x2.sim_dt = dt;
x2.dt = dt;


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


% ok: 2, 3, 4, 5, 7, 8, 11
for show_this = 10



	for qq = 1:length(conds)
		x.AB.(conds{qq}).gbar = params(qq, show_this);
		x2.AB.(conds{qq}).gbar = params(qq, show_this);
	end

	max_dt = 1e2;
	K = 1:max_dt;
	all_dt = K(rem(max_dt,K) == 0);
	all_dt = all_dt/1e3;



	x.sim_dt = 1e-6;
	x.dt = .1;
	x.reset;
	x.t_end = 2e3;

	x2.sim_dt = .01;
	x2.dt = .1;
	x2.reset;
	x2.t_end = 2e3;

	% show the voltage traces using the ode solver with various tolerances

	figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

	% exp Euler using xolotl
	x.verbosity = 99;
	V_exp = x.integrate;

	time = vectorise(x.dt:x.dt:x.t_end)*1e-3;
	subplot(2,2,1); hold on
	plot(time,V_exp,'k')
	title('Exponential Euler')
	set(gca,'XLim',[0 2])
	xlabel('Time (s)')
	ylabel('V_m (mV)')
	set(gca,'YLim',[-80 50])
	drawnow

	% rk4 using xolotl
	V_rk4 = x2.integrate;
	subplot(2,2,2); hold on
	plot(time,V_rk4,'k')
	title('rk4')
	set(gca,'XLim',[0 2])
	xlabel('Time (s)')
	ylabel('V_m (mV)')
	set(gca,'YLim',[-80 50])
	drawnow

	% ode23t 
	[t, n] = ode23tb(@(t, x) neuron_standalone(t, x, params(:, show_this)), [0 2], [0 0 0 0 0 0 0 1 1 1 1 -60 0.05*10^(-3)]);
	V_ode23t = interp1(t,n(:,12),time);

	subplot(2,2,3); hold on
	plot(time,V_ode23t,'k')
	title('ode23t')
	set(gca,'XLim',[0 2])
	xlabel('Time (s)')
	ylabel('V_m (mV)')
	set(gca,'YLim',[-80 50])
	drawnow

	% ode45
	[t, n] = ode45(@(t, x) neuron_standalone(t, x, params(:, show_this)), [0 2], [0 0 0 0 0 0 0 1 1 1 1 -60 0.05*10^(-3)]);
	V_ode45 = interp1(t,n(:,12),time);
	subplot(2,2,4); hold on
	plot(time,V_ode45,'k')
	title('ode45')
	set(gca,'XLim',[0 2])
	xlabel('Time (s)')
	ylabel('V_m (mV)')
	set(gca,'YLim',[-80 50])
	drawnow
	prettyFig('plw',1.5,'lw',1);

	% now plot them one on top of the other to compare them

	last_spike = max(nonnans(xolotl.findNSpikeTimes(V_exp,1e3)));
	a = max([last_spike - 1e3,1]);
	zz = a + 2e3;

	figure('outerposition',[300 300 1200 900],'PaperUnits','points','PaperSize',[1200 900]); hold on
	subplot(3,1,1); hold on
	plot(time(a:zz), V_ode45(a:zz),'k')
	plot(time(a:zz), V_ode23t(a:zz),'r')
	legend({'ode45','ode23t'})
	set(gca,'YLim',[-80 50])
	ylabel('V_m (mV)')

	subplot(3,1,2); hold on
	plot(time(a:zz), V_ode45(a:zz),'k')
	plot(time(a:zz), V_exp(a:zz),'r')
	legend({'ode45','exp Euler'})
	set(gca,'YLim',[-80 50])
	ylabel('V_m (mV)')

	subplot(3,1,3); hold on
	plot(time(a:zz), V_ode45(a:zz),'k')
	plot(time(a:zz), V_rk4(a:zz),'r')
	legend({'ode45','rk4'})
	set(gca,'YLim',[-80 50])
	xlabel('Time (s)')
	ylabel('V_m (mV)')

	prettyFig('plw',1.5,'lw',1);

	dfsd

	% save things
	print(['~/Desktop/exp/' mat2str(show_this) '_comp.eps'],'-depsc')
	close(gcf)
	print(['~/Desktop/exp/exp' mat2str(show_this) '_traces.eps'],'-depsc')
	close(gcf)

end

return



for show_this = 1:11


	% make a curve of chosen time step vs. AbsTol for the ode solver
	all_tol = logspace(log10(show_tol(1)),log10(show_tol(end)),n_tol);
	metrics = repmat(struct('dt',all_tol*NaN,'firing_rate',all_tol*NaN,'burst_period',all_tol*NaN,'duty_cycle',all_tol*NaN),1,4);

	handles.summary_figure = figure('outerposition',[300 300 1200 900],'PaperUnits','points','PaperSize',[1200 900]); hold on

	handles.ode_time = subplot(2,2,1); hold on
	set(handles.ode_time,'XScale','log','YScale','log')
	handles.ode23t_min_dt = plot(handles.ode_time,all_tol,NaN*all_tol,'g-o');
	handles.ode45_min_dt = plot(handles.ode_time,all_tol,NaN*all_tol,'r-o');
	xlabel(handles.ode_time,'Tolerance of ODE solver')
	ylabel(handles.ode_time,'Chosen Timestep (ms)')


	handles.burst_period = subplot(2,2,2); hold on
	handles.firing_rate = subplot(2,2,3); hold on
	handles.duty_cycle = subplot(2,2,4); hold on

	set(handles.burst_period,'XScale','log')
	xlabel(handles.burst_period,'Time step (ms)')
	ylabel(handles.burst_period,'Burst period (s)')


	set(handles.duty_cycle,'XScale','log')
	xlabel(handles.duty_cycle,'Time step (ms)')
	ylabel(handles.duty_cycle,'Duty cycle')

	set(handles.firing_rate,'XScale','log')
	xlabel(handles.firing_rate,'Time step (ms)')
	ylabel(handles.firing_rate,'Firing rate (Hz)')

	T = t_end/1e3;
	time = vectorise(.1:.1:t_end);

	disp('Varying tolerance on ODE solvers...')

	for i = 1:length(all_tol)

		options = odeset('RelTol',all_tol(i),'MaxStep',100,'NormControl','on','InitialStep',1e-6);

		% do ode23t
		[t, n] = ode23t(@(t, x) neuron_standalone(t, x, params(:, show_this)), [0 T], [0 0 0 0 0 0 0 1 1 1 1 -60 0.05*10^(-3)],options);

		t = t*1e3; % in ms

		metrics(1).dt(i) = min(diff(t(round(length(t)/2):end)))*1e-3;

		handles.ode23t_min_dt.YData = metrics(1).dt;

		% resample to sensible units
		V = interp1(t,n(:,12),time);
		Ca = interp1(t,n(:,13),time);

		% measyre the burst frequency and other metrics
		bm = psychopomp.findBurstMetrics(V(t_transient*10:end),Ca(t_transient*10:end));

			% save 
		metrics(1).firing_rate(i) =  xolotl.findNSpikes(V(t_transient*10:end))/(t_end-t_transient)*1e3;
		metrics(1).duty_cycle(i) = bm(9);
		metrics(1).burst_period(i) = bm(1)*1e-4;

		% do ode45
		[t, n] = ode45(@(t, x) neuron_standalone(t, x, params(:, show_this)), [0 T], [0 0 0 0 0 0 0 1 1 1 1 -60 0.05*10^(-3)],options);

		t = t*1e3; % in ms
		metrics(2).dt(i) = min(diff(t(round(length(t)/2):end)))*1e-3;

		handles.ode45_min_dt.YData = metrics(2).dt;
		

		% resample to sensible units
		V = interp1(t,n(:,12),time);
		Ca = interp1(t,n(:,13),time);

		if ~any(isnan(V))

			% measyre the burst frequency and other metrics
			bm = psychopomp.findBurstMetrics(V(t_transient*10:end),Ca(t_transient*10:end));

				% save 
			metrics(2).firing_rate(i) =  xolotl.findNSpikes(V(t_transient*10:end))/(t_end-t_transient)*1e3;
			metrics(2).duty_cycle(i) = bm(9);
			metrics(2).burst_period(i) = bm(1)*1e-4;

		end

		drawnow
	end


	disp('Using xolotl and varying time step')

	% set params
	for qq = 1:length(conds)
		x.AB.(conds{qq}).gbar = params(qq, show_this);
		x2.AB.(conds{qq}).gbar = params(qq, show_this);
	end



	max_dt = 1e2;
	K = 1:max_dt;
	all_dt = K(rem(max_dt,K) == 0);
	all_dt = all_dt/1e3;


	% get rid of a transient quickly
	x.sim_dt = .1;
	x.dt = .1;
	x.reset;
	x.t_end = t_transient;
	x.closed_loop = true;
	x.integrate;
	x.closed_loop = false;
	x.t_end = t_end - t_transient;

	% get rid of a transient quickly
	x2.sim_dt = .1;
	x2.dt = .1;
	x2.reset;
	x2.t_end = t_transient;
	x2.closed_loop = true;
	x2.integrate;
	x2.closed_loop = false;
	x2.t_end = t_end - t_transient;

	metrics(4).dt = all_dt;
	metrics(3).dt = all_dt;
	for i = 3:4
		metrics(i).firing_rate = NaN*metrics(i).dt;
		metrics(i).duty_cycle = NaN*metrics(i).dt;
		metrics(i).burst_period = NaN*metrics(i).dt;
	end

	for i = length(all_dt):-1:1
		disp(i)
		% exponentiual euler
		x.sim_dt = all_dt(i);

		[V,Ca] = x.integrate;

		bm = psychopomp.findBurstMetrics(V,Ca(:,1));
		metrics(4).firing_rate(i) =  xolotl.findNSpikes(V)/(t_end-t_transient)*1e3;
		metrics(4).duty_cycle(i) = bm(9);
		metrics(4).burst_period(i) = bm(1)*1e-4;

		% now use the rk4 solver in xolotl
		x2.sim_dt = all_dt(i);

		[V,Ca] = x2.integrate;

		bm = psychopomp.findBurstMetrics(V,Ca(:,1));
		metrics(3).firing_rate(i) =  xolotl.findNSpikes(V)/(t_end-t_transient)*1e3;
		metrics(3).duty_cycle(i) = bm(9);
		metrics(3).burst_period(i) = bm(1)*1e-4;
	end



	% plot burst periods 
	plot(handles.burst_period,metrics(1).dt,metrics(1).burst_period,'g-o')
	plot(handles.burst_period,metrics(2).dt,metrics(2).burst_period,'r-o')
	plot(handles.burst_period,metrics(3).dt,metrics(3).burst_period,'b-o')
	plot(handles.burst_period,metrics(4).dt,metrics(4).burst_period,'k-o')

	% plot duty cycle
	plot(handles.duty_cycle,metrics(1).dt,metrics(1).duty_cycle,'g-o')
	plot(handles.duty_cycle,metrics(2).dt,metrics(2).duty_cycle,'r-o')
	plot(handles.duty_cycle,metrics(3).dt,metrics(3).duty_cycle,'b-o')
	plot(handles.duty_cycle,metrics(4).dt,metrics(4).duty_cycle,'k-o')

	% plot firing rate
	plot(handles.firing_rate,metrics(1).dt,metrics(1).firing_rate,'g-o')
	plot(handles.firing_rate,metrics(2).dt,metrics(2).firing_rate,'r-o')
	plot(handles.firing_rate,metrics(3).dt,metrics(3).firing_rate,'b-o')
	plot(handles.firing_rate,metrics(4).dt,metrics(4).firing_rate,'k-o')


	% get some nice yaxis action
	m = nanmin([metrics.firing_rate]);
	M = nanmax([metrics.firing_rate]);
	r = M - m;
	if r == 0
		r = 1;
	end
	

	prettyFig('fs',18,'plw',1.5,'lw',0.5,'tick_length',5);

	set(handles.firing_rate,'YLim',[m- r/2, M + r/2])
	set(handles.duty_cycle,'YLim',[0 1])
	set(handles.burst_period,'YLim',[0 4])

	drawnow

	figure(handles.summary_figure)
	print(['~/Desktop/exp/' mat2str(show_this) '_metrics.eps'],'-depsc')
	close(handles.summary_figure)

end






