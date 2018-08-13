% this script makes a figure that benchmarks xolotl
% and other sim. software using a HH model and a bursting
% STG model

figure('outerposition',[100 100 1550 700],'PaperUnits','points','PaperSize',[1550 700]); hold on
for i = 8:-1:1
	ax(i) = subplot(2,4,i); hold on
    set(ax(i),'XScale','log','YScale','log')
end

for i = [1 2 5 6]
    xlabel(ax(i),'\Deltat (ms)')
end

for i = [1 3 5 7]
    ylabel(ax(i),'Speed (X realtime)')
end


for i = [2 6]
    ylabel(ax(i),'Simulation error (a.u.)')
end


for i = [3 7]
    xlabel(ax(i),'t_{end} (ms)')
end

for i = [4 8]
    ylabel(ax(i),'Speed*N (X realtime)')
    xlabel(ax(i),'N')
end





% perform benchmarking and plot data
disp('Begin xolotl HH')
testXolotlHH(ax); drawnow


disp('Begin NEURON HH')
testNeuronHH(ax); drawnow




disp('Begin xolotl STG')
testXolotlSTG(ax(5:end)); drawnow


prettyFig('lw',.5,'plw',1.5,'tick_length',.03);
return



disp('Begin DynaSim HH')
testDynaSimHH(ax); drawnow








disp('Begin DynaSim STG')
testDynaSimSTG(ax); drawnow






return









disp('Begin NEURON STG')
testNeuronSTG(ax); drawnow
