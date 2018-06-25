% this script makes a figure that benchmarks xolotl
% and other sim. software using a HH model and a bursting
% STG model

;;     ;; ;;     ;;    ;;     ;;  ;;;;;;;  ;;;;;;;;  ;;;;;;;; ;;       
;;     ;; ;;     ;;    ;;;   ;;; ;;     ;; ;;     ;; ;;       ;;       
;;     ;; ;;     ;;    ;;;; ;;;; ;;     ;; ;;     ;; ;;       ;;       
;;;;;;;;; ;;;;;;;;;    ;; ;;; ;; ;;     ;; ;;     ;; ;;;;;;   ;;       
;;     ;; ;;     ;;    ;;     ;; ;;     ;; ;;     ;; ;;       ;;       
;;     ;; ;;     ;;    ;;     ;; ;;     ;; ;;     ;; ;;       ;;       
;;     ;; ;;     ;;    ;;     ;;  ;;;;;;;  ;;;;;;;;  ;;;;;;;; ;;;;;;;; 



figure('outerposition',[100 100 1550 666],'PaperUnits','points','PaperSize',[1550 666]); hold on
for i = 10:-1:1
	ax(i) = subplot(2,5,i); hold on
end


testXolotlHH(ax);


testDynaSimHH(ax);


return

%% Add DynaSim Simulations
if isempty(cache('dynasim_HH'))
	DynaSim = dynasim_HH;
	cache('dynasim_HH',DynaSim)
else
	DynaSim = cache('dynasim_HH')
end
plot(ax(2), all_dt, DynaSim.S, 'b-o')
plot(ax(3), all_dt, DynaSim.Q, 'b-o')



%% Add DynaSim Simulations

DynaSim = load('data_HH_time.mat')
plot(ax(4), all_t_end, DynaSim.S, 'b-o')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HODGKIN-HUXLEY MODEL: NUMBER OF COMPARTMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nComps      = [1, 2, 4, 8, 16, 32, 64, 128, 250, 500, 1000];

all_sim_time = NaN * nComps;

h0 = GetMD5(nComps);
[~, h1] = x.md5hash;
h = GetMD5([h0,h1]);

if isempty(cache(h))

	for i = 1:length(nComps)
		disp(i)

		% set up xolotl object
		x = xolotl;
		x.add('compartment', 'HH', 'Cm', 10, 'A', 0.01);
		x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
		x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
		x.HH.add('Leak', 'gbar', 1, 'E', -50);
		x.I_ext = .2;
		x.integrate;
		x.snapshot('zero');
		x.closed_loop = false;
		% make n compartments
		x.replicate('AB', nComps(i));
		x.t_end = 30e3;
		x.dt = 0.1;
		x.integrate;
		% simulate
		tic;
		x.integrate;
		all_sim_time(i) = toc;
	end

	cache(h,all_sim_time)

else
	all_sim_time = cache(h);
end

S = all_t_end./all_sim_time;
S = S*1e-3;

plot(ax(5),nComps,S,'k-o')
set(ax(5),'XScale','log','YScale','log')
xlabel(ax(5),'N')
ylabel(ax(5),'Speed (X realtime)')

%% Add DynaSim Simulations

DynaSim = load('data_HH_time.mat')
plot(ax(5), nComps, DynaSim.S, 'b-o')

 ;;;;;;  ;;;;;;;;  ;;;;;;
;;    ;;    ;;    ;;    ;;
;;          ;;    ;;
 ;;;;;;     ;;    ;;   ;;;;
      ;;    ;;    ;;    ;;
;;    ;;    ;;    ;;    ;;
 ;;;;;;     ;;     ;;;;;;

;;    ;; ;;;;;;;; ;;     ;; ;;;;;;;;   ;;;;;;;  ;;    ;;
;;;   ;; ;;       ;;     ;; ;;     ;; ;;     ;; ;;;   ;;
;;;;  ;; ;;       ;;     ;; ;;     ;; ;;     ;; ;;;;  ;;
;; ;; ;; ;;;;;;   ;;     ;; ;;;;;;;;  ;;     ;; ;; ;; ;;
;;  ;;;; ;;       ;;     ;; ;;   ;;   ;;     ;; ;;  ;;;;
;;   ;;; ;;       ;;     ;; ;;    ;;  ;;     ;; ;;   ;;;
;;    ;; ;;;;;;;;  ;;;;;;;  ;;     ;;  ;;;;;;;  ;;    ;;


% now we set up a STG-like neuron
x = xolotl;
x.add('compartment','AB','A',0.0628,'phi',90,'vol',.0628);

x.AB.add('liu/NaV','gbar',@() 115/x.AB.A,'E',30);
x.AB.add('liu/CaT','gbar',@() 1.44/x.AB.A,'E',30);
x.AB.add('liu/CaS','gbar',@() 1.7/x.AB.A,'E',30);
x.AB.add('liu/ACurrent','gbar',@() 15.45/x.AB.A,'E',-80);
x.AB.add('liu/KCa','gbar',@() 61.54/x.AB.A,'E',-80);
x.AB.add('liu/Kd','gbar',@() 38.31/x.AB.A,'E',-80);
x.AB.add('liu/HCurrent','gbar',@() .6343/x.AB.A,'E',-20);
x.AB.add('Leak','gbar',@() 0.0622/x.AB.A,'E',-50);
x.t_end = 1e4;
x.integrate;
x.snapshot('zero');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STOMATOGASTRIC MODEL: TIME-STEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x.t_end = 10e3;

max_dt      = 1e3;
K           = 1:max_dt;
all_dt          = K(rem(max_dt,K) == 0);
all_dt          = all_dt/1e3;

all_sim_time = NaN*all_dt;
all_metrics = NaN(length(all_dt),10);

h0 = GetMD5(all_dt);
[~, h1] = x.md5hash;
h = GetMD5([h0,h1]);

if isempty(cache(h))

	for i = length(all_dt):-1:1


		disp(i)
		x.sim_dt = all_dt(i);
		x.dt = 1;

		tic
		[V,Ca] = x.integrate;
		all_sim_time(i) = toc;

		all_metrics(i,:) = psychopomp.findBurstMetrics(V,Ca(:,1),.3,.1,-20);

	end

	cache(h,all_metrics,all_sim_time)

else
	[all_metrics,all_sim_time] = cache(h);
end

% delete the last one because the first sim is slow for
% trivial reasons involving matlab compiling
all_metrics(end,:) = [];
all_sim_time(end) = [];
all_dt(end) = [];

% measure Q
T0 = all_metrics(1,1);
N0 = all_metrics(1,2);
D0 = all_metrics(1,9);

E_STG = zeros(3,length(all_metrics));
E_STG(1,:) = abs(all_metrics(:,1) - T0)./T0;
E_STG(2,:) = abs(all_metrics(:,2) - N0)./N0;
E_STG(3,:) = abs(all_metrics(:,9) - D0)./D0;
E_STG = sum(E_STG);




S = x.t_end./all_sim_time;
S = S*1e-3;


plot(ax(7),all_dt,S,'k-o')
set(ax(7),'XScale','log','YScale','log')
xlabel(ax(7),'\Deltat (ms)')
ylabel(ax(7),'Speed (X realtime)')

plot(ax(8),all_dt,E_STG,'k-o')
set(ax(8),'XScale','log','YScale','log')
xlabel(ax(8),'\Deltat (ms)')
ylabel(ax(8),'Simulation error (\epsilon_{STG})')

%% Add DynaSim Simulations

DynaSim = load('data_STG_dt.mat')
plot(ax(7), all_dt, DynaSim.S, 'b-o')
plot(ax(8), all_dt, DynaSim.Q, 'b-o')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STOMATOGASTRIC MODEL: SIMULATION TIME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x.reset('zero');
x.dt = .1;
x.sim_dt = .1;
all_t_end = unique(round(logspace(0,6,50)));
all_sim_time = NaN*all_t_end;
x.closed_loop = true;


h0 = GetMD5(all_t_end);
[~, h1] = x.md5hash;
h = GetMD5([h0,h1]);

if isempty(cache(h))
	for i = 1:length(all_t_end)
		disp(i)

		x.t_end = all_t_end(i);

		tic
		x.integrate;
		all_sim_time(i) = toc;

	end

	cache(h,all_sim_time)

else
	all_sim_time = cache(h);
end

S = all_t_end./all_sim_time;
S = S*1e-3;

plot(ax(9),all_t_end,S,'k-o')
set(ax(9),'XScale','log','YScale','log')
xlabel(ax(9),'t_{end} (ms)')
ylabel(ax(9),'Speed (X realtime)')

%% Add DynaSim Simulations

DynaSim = load('data_STG_time.mat')
plot(ax(9), all_t_end, DynaSim.S, 'b-o')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STOMATOGASTRIC MODEL: NUMBER OF COMPARTMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nComps      = [1, 2, 4, 8, 16, 32, 64, 128, 250, 500, 1000];

all_sim_time = NaN * nComps;

h0 = GetMD5(nComps);
[~, h1] = x.md5hash;
h = GetMD5([h0,h1]);

if isempty(cache(h))

	for i = 1:length(nComps)
		disp(i)

		% set up xolotl object
		x = xolotl;
		x.add('compartment','AB','A',0.0628,'phi',90,'vol',.0628);
		x.AB.add('liu/NaV','gbar',@() 115/x.AB.A,'E',30);
		x.AB.add('liu/CaT','gbar',@() 1.44/x.AB.A,'E',30);
		x.AB.add('liu/CaS','gbar',@() 1.7/x.AB.A,'E',30);
		x.AB.add('liu/ACurrent','gbar',@() 15.45/x.AB.A,'E',-80);
		x.AB.add('liu/KCa','gbar',@() 61.54/x.AB.A,'E',-80);
		x.AB.add('liu/Kd','gbar',@() 38.31/x.AB.A,'E',-80);
		x.AB.add('liu/HCurrent','gbar',@() .6343/x.AB.A,'E',-20);
		x.AB.add('Leak','gbar',@() 0.0622/x.AB.A,'E',-50);
		x.t_end = 1e4;
		x.integrate;
		x.snapshot('zero');
		% make n compartments
		x.replicate('AB', nComps(i));
		x.t_end = 30e3;
		x.dt = 0.1;
		x.integrate;
		% simulate
		tic;
		x.integrate;
		all_sim_time(i) = toc;
	end

	cache(h,all_sim_time)

else
	all_sim_time = cache(h);
end

S = all_t_end./all_sim_time;
S = S*1e-3;

plot(ax(10),nComps,S,'k-o')
set(ax(10),'XScale','log','YScale','log')
xlabel(ax(10),'N')
ylabel(ax(10),'Speed (X realtime)')

%% Add DynaSim Simulations

DynaSim = load('data_STG_nComps.mat')
plot(ax(10), nComps, DynaSim.S, 'b-o')


prettyFig('plw',1.5,'lw',1.5,'fs',15);
