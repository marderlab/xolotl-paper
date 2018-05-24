%% Figure 7: Benchmarking Xolotl against DynaSim and NEURON

% create figure
fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;

% speed versus time-step & accuracy vs. time-step
ax(1) = subplot(1,3,1); hold on
ax(1).Tag = 'Q vs. dt & r2 vs. dt';
% accuracy vs. time-step
ax(2) = subplot(1,3,2); hold on
ax(2).Tag = 'Q vs. dt & r2 vs. dt';
% speed versus time span
ax(3) = subplot(1,3,3); hold on
ax(3).Tag = 'Q vs. t_end';

% set up xolotl object
x = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);

t_end = 0.5e3;
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
% simulate a hodgkin-huxley model over a series of time-resolutions

% set up time-resolution vector
max_dt    = 1000;
k         = 1:max_dt;
dt        = k(rem(max_dt, k) == 0) / 1e3;

% set up outputs
sim_time          = NaN(length(dt), 3); % duration of runtime
r2                = NaN(length(dt), 3); % correlation coefficient

% perform benchmark for xolotl
x.sim_dt          = dt(1);
x.dt              = max_dt / 1e3;

% set up "best-case"  for accuracy
x.sim_dt = dt(1);
x.dt = max_dt*1e-3;
tic
V0 = x.integrate(0.2);
V0_diff = diff(V0);
sim_time(1,1) = toc;

% run benchmark test
for i = 2:length(dt)

	x.sim_dt = dt(i);
	tic
	V = x.integrate(0.2);
	sim_time(i,1) = toc;

	% measure distance b/w diff-embedded attractors
	V_diff = diff(V);

	this_cost = 0;
	for j = 2:10:length(V0_diff)
		for k = 1:size(V,2)
			this_cost = this_cost + min(sqrt((V0_diff(j,k) - V_diff(:,k)).^2 + (V0(2:end,k) - V(2:end,k)).^2));
		end
	end

	r2(i,1) = this_cost;

end
return
% perform benchmark for DynaSim
sim_dt            = dt(1);
sampling          = max_dt / 1e3;

% precompile
data              = dsSimulate(equations, 'solver', 'rk2', 'tspan', [0 t_end], 'dt', sim_dt, 'compile_flag', 1);

% set up "best-case" for accuracy
tic
data0             = dsSimulate(equations, 'solver', 'rk2', 'tspan', [0 t_end], 'dt', dt(1), 'compile_flag', 1, 'downsample_factor', 1/dt(1));
sim_time(1,:)     = toc;
V0                = data0.(data0.labels{1});
V0_diff           = diff(V0);

for ii = 2:length(dt)
  textbar(ii, length(dt))
  sim_dt          = dt(ii);
  tic
  data            = dsSimulate(equations, 'solver', 'rk2', 'tspan', [0 t_end], 'dt', sim_dt, 'compile_flag', 1, 'downsample_factor', 1/sim_dt);
  sim_time(ii, 2) = toc;

  % measure distance between diff-embedded attractors
  V               = data.(data.labels{1});
  V_diff          = diff(V);
  this_cost       = 0;
  for qq = 2:10:length(V0_diff)
    for ww = 1:size(V, 2)
      this_cost = this_cost + min(sqrt((V0_diff(qq,ww) - V_diff(:,ww)).^2 + (V0(2:end,ww) - V(2:end,ww)).^2));
    end
  end
  % save r-squared value
  r2(ii, 2)       = this_cost;
end

%% Plot Benchmark Test #1

c = lines(100);

% define speed
Qfactor = t_end / 1e3 ./ sim_time;

% sim-time vs. dt
plot(ax(1), dt, Qfactor, '-+')
xlabel(ax(1), 'time step (ms)')
ylabel(ax(1), 'speed factor')
set(ax(1),'YScale','log','XScale','log')

% error vs. dt
plot(ax(2), dt, r2, '-o')
xlabel(ax(2), 'time step (ms)')
ylabel(ax(2), 'error (a.u.)')
set(ax(2),'YScale','log','XScale','log')

prettyFig;

return


%% Benchmark Test #1
% simulate a hodgkin-huxley model neuron over a series of simulation times

t_end   = round(logspace(1,6,20));
Qfactor = NaN(length(t_end), 3);

% test xolotl

% set up simulation parameters for xolotl
x.dt    = 0.1; % ms

% perform benchmarking
for ii = 1:length(t_end)
  % set the end time
  x.t_end = t_end(ii);
  % begin timing
  tic;
  x.integrate(0.2);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor(ii, 1) = t_end(ii) / t_sim;
end

% test DynaSim

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

for ii = 1:length(t_end)
  % begin timing
  tic;
  data = dsSimulate(equations, 'solver', 'rk2', 'tspan', [0 t_end(ii)], ...
    'dt', 0.1, 'compile_flag', 1);
  t_sim = toc;
  % compute the speed as real-time / simulation-time
  Qfactor(ii, 2) = t_end(ii) / t_sim;
end

% plot the results

figure;
plot(t_end, Qfactor, '-o')
xlabel('Simulation time (ms)')
set(gca,'XScale','log','YScale','log','XTick',logspace(1,6,6))
ylabel('Speed (X realtime)')
legend({'xolotl', 'DynaSim'})

prettyFig();
