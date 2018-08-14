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


[Q, S, all_dt] = loadNeuronData('./neuron/neuron_STG_benchmark1');

% plot simulation speed vs. time step on axes #2
plot(ax(1), all_dt, S, 'b-o')

% plot simulation error vs time step on axes #3
plot(ax(2),all_dt, Q, 'b-o')




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


all_t_end   = unique(round(logspace(0,6,20)));
S           = csvread('./neuron/neuron_STG_benchmark2.csv');

% plot simulation speed vs. simulation time on axes #4
plot(ax(3),all_t_end, S, 'b-o')

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


% nComps      = unique(round(logspace(0,3,21)));
nComps      = [1, 2, 4, 8, 16, 32, 64, 128, 250, 500, 1000];
S           = csvread('./neuron/neuron_STG_benchmark3.csv');

S = S(:).*nComps(:);

% plot simulation speed vs. number of compartments on axes #5
plot(ax(4),nComps, S, 'b-o')
