% simulate DynaSim Hodgkin-Huxley model
% with same specifications as figure_benchmark_2

function testDynaSimHH(ax)

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


%% Increasing Time Step


% simulation time
t_end       = 30e3;

% make a vector of dt to vary
max_dt = 1e3;
K = 1:max_dt;
all_dt = K(rem(max_dt,K) == 0);
all_dt = all_dt/1e3;

% set up output vectors
all_sim_time= NaN*all_dt;
all_f       = NaN*all_dt;

% downsampling time
time        = all_dt(end) * (1:(t_end / max(all_dt)));


all_V = NaN(ceil(t_end/max(all_dt)),length(all_dt));

h = ['DS_' GetMD5(which(mfilename),'File')];

if isempty(cache(h))

	for i = length(all_dt):-1:1
		disp(i)

		% perform simulation
		tic;
		data = dsSimulate(equations, 'solver', 'rk2', 'tspan', [all_dt(i) t_end], 'dt', all_dt(i), 'compile_flag', 0);
		all_sim_time(i) = toc;


		all_V(:,i) = interp1(all_dt(i)*(1:length(data.(data.labels{1}))), data.(data.labels{1}), time);

	end

	cache(h,all_V,all_sim_time)
else
	[all_V,all_sim_time] = cache(h);
end

for i = length(all_dt):-1:1
	if any(isnan(all_V(:,i)))
		continue
	end
	all_f(i) = xolotl.findNSpikes(all_V(:,i),-20);
	all_f(i) = all_f(i)/(t_end*1e-3);
end

% now measure the errors using the LeMasson matrix
[M0, V_lim, dV_lim] = xolotl.V2matrix(all_V(:,1));

for i = length(all_dt):-1:2
	M = xolotl.V2matrix(all_V(:,i),V_lim, dV_lim);
	matrix_error(i) = xolotl.matrixCost(M0,M);
end


% delete the last one because the first sim is slow
all_f(end) = [];
matrix_error(end) = [];
all_sim_time(end) = [];
all_dt(end) = [];


% measure speed
S = t_end ./ all_sim_time;
S = S * 1e-3;


plot(ax(2),all_dt,S,'r-o')
set(ax(2),'XScale','log','YScale','log')
xlabel(ax(2),'\Deltat (ms)')
ylabel(ax(2),'Speed (X realtime)')

plot(ax(3),all_dt,matrix_error,'r-o')
set(ax(3),'XScale','log','YScale','log')
xlabel(ax(3),'\Deltat (ms)')
ylabel(ax(3),'Simulation error (\epsilon_{HH})')


%% Increasing Simulation Time


dt          = 0.1;
all_t_end   = unique(round(logspace(0,6,20)));
all_sim_time = NaN*all_t_end;

h = ['DS_' GetMD5(all_t_end)];

if isempty(cache(h))

	disp('Increasing t_end for dynasim')
	for ii = 1:length(all_t_end)
		disp(ii)

		tic
		data = dsSimulate(equations, 'solver', 'rk2', 'tspan', [dt all_t_end(ii)], 'dt', dt, 'compile_flag', 0);
		all_sim_time(ii) = toc;
	end

	S  = all_t_end ./ all_sim_time;
	S  = S * 1e-3;
	cache(h,S)

else
	S = cache(h);
end

plot(ax(4),all_t_end,S,'r-o')
set(ax(4),'XScale','log','YScale','log')
xlabel(ax(4),'t_{end} (ms)')
ylabel(ax(4),'Speed (X realtime)')


%% Increasing Number of Compartments


dt          = 0.1;  % ms
t_end       = 30e3; % ms
nComps      = unique(round(logspace(0,3,21)));
all_sim_time = NaN*nComps;

h = ['DS_' GetMD5(nComps)];

if isempty(cache(h))

	disp('Increasing number of compartments for dynasim')
  
	for ii = 1:length(nComps)
		disp(ii)

    % set up dynasim structure
    clear ds
    ds = struct; % holds the DynaSim population information
    ds.populations.name       = 'test';
    ds.populations.size       = nComps(ii);
    ds.populations.equations  = equations;

    % give dynasim a trial run
    dsSimulate(ds, 'solver', 'rk2', 'tspan', [dt t_end], 'dt', dt, 'compile_flag', 0);

    % time dynasim
		tic
		data = dsSimulate(ds, 'solver', 'rk2', 'tspan', [dt t_end], 'dt', dt, 'compile_flag', 0);
		all_sim_time(ii) = toc;
	end

	S  = all_t_end ./ all_sim_time;
	S  = S * 1e-3;
	cache(h,S)

else
	S = cache(h);
end

plot(ax(5),nComps,S,'r-o')
set(ax(5),'XScale','log','YScale','log')
xlabel(ax(5),'compartments')
ylabel(ax(5),'Speed (X realtime)')
