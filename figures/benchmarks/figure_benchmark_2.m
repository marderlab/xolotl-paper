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

% perform benchmarking and plot data
testXolotlHH(ax);
testDynaSimHH(ax);
testNeuronHH(ax);

testXolotlSTG(ax);
testDynaSimSTG(ax);
testNeuronSTG(ax);

% add axis labels and scaling
set(ax(2),'XScale','log','YScale','log')
xlabel(ax(2),'\Deltat (ms)')
ylabel(ax(2),'Speed (X realtime)')

set(ax(3),'XScale','log','YScale','log')
xlabel(ax(3),'\Deltat (ms)')
ylabel(ax(3),'Simulation error (\epsilon_{HH})')

set(ax(4),'XScale','log','YScale','log')
xlabel(ax(4),'t_{end} (ms)')
ylabel(ax(4),'Speed (X realtime)')

set(ax(5),'XScale','log','YScale','log')
xlabel(ax(5),'N')
ylabel(ax(5),'Speed (X realtime)')

set(ax(2+5),'XScale','log','YScale','log')
xlabel(ax(2+5),'\Deltat (ms)')
ylabel(ax(2+5),'Speed (X realtime)')

set(ax(3+5),'XScale','log','YScale','log')
xlabel(ax(3+5),'\Deltat (ms)')
ylabel(ax(3+5),'Simulation error (\epsilon_{HH})')

set(ax(4+5),'XScale','log','YScale','log')
xlabel(ax(4+5),'t_{end} (ms)')
ylabel(ax(4+5),'Speed (X realtime)')

set(ax(5+5),'XScale','log','YScale','log')
xlabel(ax(5+5),'N')
ylabel(ax(5+5),'Speed (X realtime)')
