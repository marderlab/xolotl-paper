% this script makes a figure that benchmarks xolotl
% and other sim. software using a HH model and a bursting
% STG model


clearvars
figure('outerposition',[100 100 1600 850],'PaperUnits','points','PaperSize',[1600 850]); hold on
for i = 8:-1:1
	ax(i) = subplot(2,4,i); hold on
    set(ax(i),'XScale','log','YScale','log')
end

for i = [1 2 5 6]
    xlabel(ax(i),'\Deltat (ms)')
end

for i = [1 3 5 7]
    ylabel(ax(i),'Relative Speed')
end


for i = [2 6]
    ylabel(ax(i),'Simulation error (a.u.)')
end


for i = [3 7]
    xlabel(ax(i),'t_{end} (ms)')
end

for i = [4 8]
    ylabel(ax(i),'Relative Speed x N')
    xlabel(ax(i),'N')
end





% perform benchmarking and plot data
disp('Begin xolotl HH')
testXolotlHH(ax); drawnow


disp('Begin NEURON HH')
testNeuronHH(ax); drawnow




disp('Begin xolotl STG')
testXolotlSTG(ax(5:end)); drawnow



disp('Begin DynaSim HH')
testDynaSimHH(ax); drawnow


disp('Begin DynaSim STG')
testDynaSimSTG(ax(5:end)); drawnow



disp('Begin NEURON STG')
testNeuronSTG(ax(5:end)); drawnow


prettyFig('lw',.5,'plw',1.5,'tick_length',.03,'fs',24);


movePlot(ax([1 5]),'left',.075)
movePlot(ax([2 6]),'left',.05)
movePlot(ax([3 7]),'left',.035)
movePlot(ax([4 8]),'left',.01)

movePlot(ax(1:4),'up',.02)

for i = 1:8
	axis(ax(i),'square')
end

% nice legends
clear l L 

l(1) = plot(ax(4),NaN,NaN,'k.','MarkerSize',34);
l(3) = plot(ax(4),NaN,NaN,'b.','MarkerSize',34);
l(2) = plot(ax(4),NaN,NaN,'r.','MarkerSize',34);

lh = legend(l,{'xolotl','DynaSim','NEURON'});
lh.Position = [0.9071    0.7416    0.0690    0.1037];
lh.Box = 'off';
labelFigure('capitalise',true,'column_first',true,'x_offset',-.02,'y_offset',-.02,'font_size',28,'font_weight','bold')