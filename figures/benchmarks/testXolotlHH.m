% this function creates a HH model in
% xolotl, and runs the benchmarks on it


function testXolotlHH(ax)


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


x.t_end = 30e3;
x.dt = 1;

;;     ;;    ;;;    ;;;;;;;;  ;;    ;;
;;     ;;   ;; ;;   ;;     ;;  ;;  ;;
;;     ;;  ;;   ;;  ;;     ;;   ;;;;
;;     ;; ;;     ;; ;;;;;;;;     ;;
 ;;   ;;  ;;;;;;;;; ;;   ;;      ;;
  ;; ;;   ;;     ;; ;;    ;;     ;;
   ;;;    ;;     ;; ;;     ;;    ;;

;;;;;;;;  ;;;;;;;; ;;       ;;;;;;;;    ;;;    ;;;;;;;;
;;     ;; ;;       ;;          ;;      ;; ;;      ;;
;;     ;; ;;       ;;          ;;     ;;   ;;     ;;
;;     ;; ;;;;;;   ;;          ;;    ;;     ;;    ;;
;;     ;; ;;       ;;          ;;    ;;;;;;;;;    ;;
;;     ;; ;;       ;;          ;;    ;;     ;;    ;;
;;;;;;;;  ;;;;;;;; ;;;;;;;;    ;;    ;;     ;;    ;;


% make a vector of dt to vary
max_dt = 1e3;
K = 1:max_dt;
all_dt = K(rem(max_dt,K) == 0);
all_dt = all_dt/1e3;

all_V = NaN(ceil(x.t_end/x.dt),length(all_dt));

h0 = GetMD5(all_dt);
[~, h1] = x.md5hash;
h = GetMD5([h0,h1]);

if isempty(cache(h))

	for i = length(all_dt):-1:1

		disp(i)
		x.sim_dt = all_dt(i);
		x.dt = 1;

		tic
		all_V(:,i) = x.integrate;
		all_sim_time(i) = toc;
	end
	cache(h,all_V,all_sim_time)
else
	[all_V,all_sim_time] = cache(h);
end


% now measure the errors using the LeMasson matrix
[M0, V_lim, dV_lim] = xolotl.V2matrix(all_V(:,1));

for i = length(all_dt):-1:2
	M = xolotl.V2matrix(all_V(:,i),V_lim, dV_lim);
	matrix_error(i) = xolotl.matrixCost(M0,M);
end


% delete the last one because the first sim is slow for
% trivial reasons involving matlab compiling

matrix_error(end) = [];
all_sim_time(end) = [];
all_dt(end) = [];

Q = matrix_error;

S = x.t_end./all_sim_time;
S = S*1e-3;

% plot simulation speed vs. time step on axes #2
plot(ax(1),all_dt,S,'k-o')

% plot simulation error vs time step on axes #3
plot(ax(2),all_dt,Q,'k-o')




;;     ;;    ;;;    ;;;;;;;;  ;;    ;;
;;     ;;   ;; ;;   ;;     ;;  ;;  ;;
;;     ;;  ;;   ;;  ;;     ;;   ;;;;
;;     ;; ;;     ;; ;;;;;;;;     ;;
 ;;   ;;  ;;;;;;;;; ;;   ;;      ;;
  ;; ;;   ;;     ;; ;;    ;;     ;;
   ;;;    ;;     ;; ;;     ;;    ;;

;;;;;;;;         ;;;;;;;; ;;    ;; ;;;;;;;;
   ;;            ;;       ;;;   ;; ;;     ;;
   ;;            ;;       ;;;;  ;; ;;     ;;
   ;;            ;;;;;;   ;; ;; ;; ;;     ;;
   ;;            ;;       ;;  ;;;; ;;     ;;
   ;;            ;;       ;;   ;;; ;;     ;;
   ;;    ;;;;;;; ;;;;;;;; ;;    ;; ;;;;;;;;



x.reset('zero');
x.dt = .1;
x.sim_dt = .1;
all_t_end = unique(round(logspace(0,6,20)));
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

% plot simulation speed vs. simulation time on axes #4
plot(ax(3),all_t_end,S,'k-o')

 ;;;;;;  ;;    ;;  ;;;;;;  ;;;;;;;; ;;;;;;;; ;;     ;;
;;    ;;  ;;  ;;  ;;    ;;    ;;    ;;       ;;;   ;;;
;;         ;;;;   ;;          ;;    ;;       ;;;; ;;;;
 ;;;;;;     ;;     ;;;;;;     ;;    ;;;;;;   ;; ;;; ;;
      ;;    ;;          ;;    ;;    ;;       ;;     ;;
;;    ;;    ;;    ;;    ;;    ;;    ;;       ;;     ;;
 ;;;;;;     ;;     ;;;;;;     ;;    ;;;;;;;; ;;     ;;

  ;;;;;;  ;;;; ;;;;;;;; ;;;;;;;;
;;    ;;  ;;       ;;  ;;
;;        ;;      ;;   ;;
 ;;;;;;   ;;     ;;    ;;;;;;
      ;;  ;;    ;;     ;;
;;    ;;  ;;   ;;      ;;
 ;;;;;;  ;;;; ;;;;;;;; ;;;;;;;;



% set up base xolotl object
clear x
x0 = xolotl;
x0.add('compartment', 'HH', 'Cm', 10, 'A', 0.01);
x0.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x0.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x0.HH.add('Leak', 'gbar', 1, 'E', -50);
x0.I_ext = .2;

x0.t_end = 30e3;
x0.sim_dt = .1;
x0.dt = .1;
x0.integrate;
x0.snapshot('zero');

nComps      = unique(round(logspace(0,3,21)));
t_end       = 30e3;

h0 = GetMD5(nComps);
[~, h1] = x0.md5hash;
h = GetMD5([h0,h1]);

if isempty(cache(h))
	disp('Varying system size...')
	for i = 1:length(nComps)
		disp(['N = ' mat2str(nComps(i))])

		% make n compartments
		clear x
		x = copy(x0);
		disp('replicating...')
		tic
		x.replicate('HH', nComps(i));
		toc

		x.t_end = 10;
		disp('compiling...')
		x.integrate;
		toc
		x.dt = 0.1;
		x.I_ext = .2*ones(nComps(i),1);
		x.t_end = 30e3;


		% simulate
		tic;
		x.integrate;
		all_sim_time(i) = toc;

		fprintf([' , t_sim = ' mat2str(all_sim_time(i)) 's\n'])

	end

	cache(h,all_sim_time)

else
	all_sim_time = cache(h);
end

S = t_end./(all_sim_time*1e3);

S = S.*nComps;

% plot simulation speed vs. number of compartments on axes #5
plot(ax(4),nComps,S,'k-o')
