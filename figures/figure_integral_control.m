%% Figure 6: Integral Control

% create a xolotl object




% tests a neuron that reproduces Fig 3 in Tim's paper


x = xolotl;
x.add('compartment','AB','A',A,'vol',A,'phi',90.6,'Ca_target',7);

g0 = 1e-1+1e-1*rand(7,1);

x.AB.add('liu/NaV','gbar',g0(1),'E',30);
x.AB.add('liu/CaT','gbar',g0(2));
x.AB.add('liu/CaS','gbar',g0(3));
x.AB.add('liu/ACurrent','gbar',g0(4),'E',-80);
x.AB.add('liu/KCa','gbar',g0(5),'E',-80);
x.AB.add('liu/Kd','gbar',g0(6),'E',-80);
x.AB.add('liu/HCurrent','gbar',g0(7),'E',-20);
x.AB.add('Leak','gbar',.0989,'E',-55);

x.AB.NaV.add('IntegralController');
x.AB.CaT.add('IntegralController');
x.AB.CaS.add('IntegralController');
x.AB.ACurrent.add('IntegralController');
x.AB.KCa.add('IntegralController');
x.AB.Kd.add('IntegralController');
x.AB.HCurrent.add('IntegralController');

% configure controller parameters
x.set('*tau_m',1e4./[1 .22 .18 .08 8 5 15])
x.set('*Controller.m',1e-1+1e-2*rand(7,1))


x.sim_dt = .1;
x.dt = 100;

x.t_end = .5e3;
[~,Ca0,C0] = x.integrate;
x.snapshot('before');

x.t_end = 9.5e3;
[~,Ca1,C1] = x.integrate;
x.snapshot('during');

x.t_end = 990e3;
[~,Ca2,C2] = x.integrate;
x.snapshot('after');

C = [C0; C1; C2];
Ca = [Ca0; Ca1; Ca2];




m = C(:,1:2:end);
g = C(:,2:2:end);

%% Make Figure

fig = figure('outerposition',[10 10 1200 900],'PaperUnits','points','PaperSize',[1200 900]); hold on;
clear ax
time = (1:length(Ca))*100*1e-3;
colours = brighten(othercolor('Mrainbow',8),.1);

% graphics
ax.gfx = subplot(3,5,1); hold on

% time traces
ax.Ca = subplot(4,5,3:5); hold on
ax.m = subplot(4,5,8:10); hold on
ax.g = subplot(4,5,13:15); hold on

% voltage traces
ax.V(1) = subplot(4,5,18); hold on
ax.V(2) = subplot(4,5,19); hold on
ax.V(3) = subplot(4,5,20); hold on

% plot Ca
temp = filter(ones(1e3,1),1e3,Ca(:,1));
plot(ax.Ca,time,x.AB.Ca_target + 0*Ca(:,1),'r--')
plot(ax.Ca,time,temp,'k')
set(ax.Ca,'XScale','log','YScale','log')
ylabel(ax.Ca,'<[Ca^2^+]>')

% plot mRNA
clear l L
for i = 1:size(m,2)
	l(i) = plot(ax.m,NaN,NaN,'MarkerSize',24,'Color',colours(i,:));
	plot(ax.m,time,m(:,i),'Color',colours(i,:));
end
set(ax.m,'XScale','log','YScale','log')
ylabel(ax.m,'mRNA')

% plot g
for i = 1:size(m,2)
	plot(ax.g,time,g(:,i),'Color',colours(i,:))
end
set(ax.g,'XScale','log','YScale','log')
ylabel(ax.g,'g (uS/mm^2)')
xlabel('Time (s)')

% show the voltage plots
x.reset('before')
x.t_end = 5e2; x.dt = .1; V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(ax.V(1),time,V,'k')
set(ax.V(1),'YLim',[-80 40])


x.reset('during')
x.t_end = 5e2; x.dt = .1; V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(ax.V(2),time,V,'k')
set(ax.V(2),'YLim',[-80 40])

x.reset('after')
x.t_end = 5e2; x.dt = .1; V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(ax.V(3),time,V,'k')
set(ax.V(3),'YLim',[-80 40])


axis(ax.V,'off')
ax.Ca.XTickLabel = '';
ax.m.XTickLabel = '';

for i = 1:3
	ax.V(i).Position(4) = .12;
end
movePlot(ax.V(1),'left',.05)
movePlot(ax.V(3),'right',.05)

prettyFig('plw',1.5,'lw',1.5,'fs',17);



return


% xolotl structure
ax(2) = subplot(3,5,6);
% xolotl printout
ax(3) = subplot(3,5,11);
% voltage traces
ax(4) = subplot(3,5,2:3); hold on;
ax(5) = subplot(3,5,4:5); hold on;
% conductance trace
ax(6) = subplot(3,5,[7:10 12:15]); hold on;

%% Make Cartoon Cell

image(ax(1), imread('figure_network_Prinz_2004.png'))
axis(ax(1), 'off');
ax(1).Tag = 'cartoon';

%% Make Xolotl Structure

image(ax(2), imread('figure_network_diagram.png'))
axis(ax(2), 'off')
ax(2).Tag = 'code_snippet';

%% Make Xolotl Readout from MATLAB

image(ax(3), imread('figure_HH_xolotl_printout.png'))
axis(ax(3), 'off')
ax(3).Tag = 'xolotl_printout';

%% Make Conductance Plots

c = lines(100);
time = x.dt*(1:length(C))*1e-3;
Cplot = C(:,2:2:end);
plot(ax(6), time, Cplot);
for ii = 1:size(Cplot,2)
	hplot(ii) = plot(ax(6), NaN, NaN, 'o', 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :), 'MarkerSize', 8);
end
set(ax(6), 'XScale', 'log', 'YScale','log', 'YTick', [1e-2 1e0 1e2 1e4], 'XLim', [0 510], 'XTick', [0 1e0 1e1 1e2 5e2])
ylabel(ax(6), {'maximal conductance'; '(\muS/mm^2)'})
xlabel('Time (s)')
leg(1) = legend(hplot, x.AB.find('conductance'), 'Location', 'EastOutside');

%% Make Voltage Plot

x.dt = .1;
x.t_end = 1e3;
V = x.integrate;
time = x.dt*(1:length(V))*1e-3;

plot(ax(4), time, V_init, '-k', 'LineWidth', 1)
plot(ax(5), time, V, '-k', 'LineWidth', 1)

set(ax(4:5), 'YLim', [-80 50], 'YTick', [-80 -50 0 50], 'XLim', [0 1.01*max(time)])
for ii = 1:2
	xlabel(ax(ii+3), 'Time (s)')
	ylabel(ax(ii+3), 'V_m (mV)')
end

%% Post-Processing

prettyFig('fs', 12)

% remove boxes
for ii = 1:length(ax)
  box(ax(ii), 'off')
end

% set axis positions
pos = [ ...
	0.0300    0.7612    0.1237    0.2138;
	0.0300    0.4616    0.1237    0.2138;
	0.0300    0.1620    0.1237    0.2138;
	0.2495    0.7388    0.2866    0.2157;
	0.6009    0.7388    0.2866    0.2157;
	0.2495    0.1612    0.6405    0.4313];
for ii = 1:length(ax)
  ax(ii).Position = pos(ii, :);
end

% set legend positions
leg.Position = [0.8995, 0.2461, 0.0975, 0.2618];

% label the subplots
% labelFigure('capitalise', true)

% split the axes for aesthetics
deintersectAxes(ax(4:6))
