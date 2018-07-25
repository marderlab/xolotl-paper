% this function creates a HH model in
% xolotl, and runs the benchmarks on it


function testNeuronHH(ax)

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

h = ['NRN_STG' GetMD5(which(mfilename),'File')];

if isempty(cache(h))

  % load the NEURON data
  disp('loading NEURON data...')
  all_V = csvread('../../neuron/neuron_HH_benchmark1_raw.csv'); % this is 3.3 GB

  % let's assume for the time being it's nSteps x nSims

  for i = length(all_dt):-1:1
    textbar(length(all_dt)-i, length(all_dt))
    V = nonnans(all_V(:,i));
  	all_f(i) = xolotl.findNSpikes(V,-20);
  	all_f(i) = all_f(i)/(t_end*1e-3);
  end

  % measure the errors using the LeMasson matrix
  V0 = nonnans(all_V(:,1));
  [M0, V_lim, dV_lim] = xolotl.V2matrix(V0);

  for i = length(all_dt):-1:2
    textbar(length(all_dt) - i, length(all_dt))
    V = nonnans(all_V(:,i));
  	M = xolotl.V2matrix(V, V_lim, dV_lim);
  	matrix_error(i) = xolotl.matrixCost(M0,M);
  end

  % delete the last one because of overhead reasons
  all_f(end) = [];
  matrix_error(end) = [];
  all_dt(end) = [];

  % store the matrix error
  Q = matrix_error;

  % store the speed
  S = csvread('../../neuron/neuron_HH_benchmark1.csv')
  S(end) = [];
  % cache the speed and error
	cache(h, Q, S)
else
	[Q, S] = cache(h);
end


% plot simulation speed vs. time step on axes #2
plot(ax(2), all_dt(:), S, 'b-o')

% plot simulation error vs time step on axes #3
plot(ax(3),all_dt, Q, 'b-o')




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


all_t_end    = [1, 2, 3, 4, 5, 7, 10, 13, 17, 22, 29, 39, 52, 69, ...
91, 121, 160, 212, 281, 373, 494, 655, 869, 1151, 1526, 2024, 2683, 3556, 4715, ...
6251, 8286, 10985, 14563, 19307, 25595, 33932, 44984, 59636, 79060, 104811, 138950, ...
184207, 244205, 323746, 429193, 568987, 754312, 1000000];
S            = csvread('../../neuron/neuron_HH_benchmark2.csv');

% plot simulation speed vs. simulation time on axes #4
plot(ax(4),all_t_end, S, 'b-o')


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


nComps      = [1, 2, 4, 8, 16, 32, 64, 128, 250, 500, 1000];
S           = csvread('../../neuron/neuron_HH_benchmark3.csv');

% plot simulation speed vs. number of compartments on axes #5
plot(ax(5),nComps, S, 'b-o')
