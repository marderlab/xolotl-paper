% this function creates a HH model in
% xolotl, and runs the benchmarks on it


function testNeuronSTG(ax)

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

% simulation time
t_end = 30000;

% make a vector to store the voltage trace
all_V = NaN(ceil(x.t_end/x.dt),length(all_dt));

h = ['NRN_' GetMD5(which(mfilename),'File')];

if isempty(cache(h))

  % load the NEURON data
  all_V = csvread('neuron_STG_benchmark1_raw.csv'); % this is 3.3 GB

  % let's assume for the time being it's nSteps x nSimsthe coup

  for i = length(all_dt):-1:1
  	all_f(i) = xolotl.findNSpikes(all_V(:,i),-20);
  	all_f(i) = all_f(i)/(t_end*1e-3);
  end

  % measure the errors using the LeMasson matrix
  [M0, V_lim, dV_lim] = xolotl.V2matrix(all_V(:,1));

  for i = length(all_dt):-1:2
  	M = xolotl.V2matrix(all_V(:,i),V_lim, dV_lim);
  	matrix_error(i) = xolotl.matrixCost(M0,M);
  end

  % delete the last one because of overhead reasons
  all_f(end) = [];
  matrix_error(end) = [];
  all_sim_time(end) = [];
  all_dt(end) = [];

  % store the matrix error
  Q = matrix_error;

  % store the speed
  S = csvread('neuron_STG_benchmark1.csv')

  % cache the speed and error
	cache(h, Q, S)
else
	[Q, S] = cache(h);
end


% plot simulation speed vs. time step on axes #2
plot(ax(2), all_dt, S, 'b-o')
set(ax(2),'XScale','log','YScale','log')
xlabel(ax(2),'\Deltat (ms)')
ylabel(ax(2),'Speed (X realtime)')

% plot simulation error vs time step on axes #3
plot(ax(3),all_dt, Q, 'b-o')
set(ax(3),'XScale','log','YScale','log')
xlabel(ax(3),'\Deltat (ms)')
ylabel(ax(3),'Simulation error (\epsilon_{HH})')




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


all_t_end    = unique(round(logspace(0,6,20)));
S            = csvread('neuron_STG_benchmark2.csv');

% plot simulation speed vs. simulation time on axes #4
plot(ax(4),all_t_end, S, 'b-o')
set(ax(4),'XScale','log','YScale','log')
xlabel(ax(4),'t_{end} (ms)')
ylabel(ax(4),'Speed (X realtime)')


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


nComps      = unique(round(logspace(0,3,21)));
S           = csvread('neuron_STG_benchmark2.csv');

% plot simulation speed vs. number of compartments on axes #5
plot(ax(5),nComps, S, 'b-o')
set(ax(5),'XScale','log','YScale','log')
xlabel(ax(5),'N')
ylabel(ax(5),'Speed (X realtime)')
