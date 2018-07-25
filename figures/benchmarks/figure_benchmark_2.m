% this script makes a figure that benchmarks xolotl
% and other sim. software using a HH model and a bursting
% STG model

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
ax(1).Visible = 'off';

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

ax(1+5).Visible = 'off';

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

% add legend to right-hand side
c = lines(3);
for ii = 1:3
	l(ii) = plot(ax(5), NaN, NaN, 'o', 'MarkerFaceColor', c(ii,:), 'MarkerEdgeColor', c(ii,:));
end
leg = legend(l, {'xolotl', 'DynaSim', 'NEURON'}, 'Location', 'northwest')

% beautify
prettyFig('fs', 12, 'plw', 3)

% remove boxes around subplots
for ii = 1:length(ax)
  box(ax(ii), 'off')
end

% fix the sizing and spacing
pos = [...
    0.1300    0.5838    0.1237    0.3412;
    0.3094    0.6232    0.1040    0.3208;
    0.4722    0.6232    0.1040    0.3208;
    0.6350    0.6232    0.1040    0.3208;
    0.7978    0.6232    0.1040    0.3208;
    0.1300    0.1100    0.1237    0.3412;
    0.3094    0.1494    0.1040    0.3208;
    0.4722    0.1494    0.1040    0.3208;
    0.6350    0.1494    0.1040    0.3208;
    0.7978    0.1494    0.1040    0.3208];

for ii = 1:length(ax)
  ax(ii).Position = pos(ii, :);
end

% set legend position
leg.Position = [0.9156, 0.8135, 0.0726, 0.1021];

% label the subplots
labelAxes(ax(2),'A','x_offset',-.03,'y_offset',-.025,'font_size',18);
labelAxes(ax(3),'B','x_offset',-.03,'y_offset',-.025,'font_size',18);
labelAxes(ax(4),'C','x_offset',-.03,'y_offset',-.025,'font_size',18);
labelAxes(ax(5),'D','x_offset',-.03,'y_offset',-.025,'font_size',18);

labelAxes(ax(7),'E','x_offset',-.03,'y_offset',-.025,'font_size',18);
labelAxes(ax(8),'F','x_offset',-.03,'y_offset',-.025,'font_size',18);
labelAxes(ax(9),'G','x_offset',-.03,'y_offset',-.025,'font_size',18);
labelAxes(ax(10),'H','x_offset',-.03,'y_offset',-.025,'font_size',18);

% break the axes
deintersectAxes(ax(1:10))
