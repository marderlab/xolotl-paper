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
