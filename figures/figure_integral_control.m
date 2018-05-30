%% Figure 6: Integral Control

% create a xolotl object
A = 0.0628; % mm^2
vol = A; % mm^3
f = 1.496; % uM/nA
tau_Ca = 200;
F = 96485; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;
Ca_target = 7; % used only when we add in homeostatic control

x = xolotl;
x.add('AB','compartment','Cm',10,'A',A,'vol',vol,'phi',phi,'Ca_out',3000,'Ca_in',0.05,'tau_Ca',tau_Ca,'Ca_target',Ca_target);

g0 = 1e-1+1e-1*rand(7,1);

x.AB.add('liu/NaV','gbar',g0(1),'E',30);
x.AB.add('liu/CaT','gbar',g0(2),'E',30);
x.AB.add('liu/CaS','gbar',g0(3),'E',30);
x.AB.add('liu/ACurrent','gbar',g0(4),'E',-80);
x.AB.add('liu/KCa','gbar',g0(5),'E',-80);
x.AB.add('liu/Kd','gbar',g0(6),'E',-80);
x.AB.add('liu/HCurrent','gbar',g0(7),'E',-20);
x.AB.add('Leak','gbar',.099,'E',-50);

% integrate before integral control to get initial network activity
x.dt 		= .1;
x.t_end = 1e3;
V_init 	= x.integrate;

tau_g = 5e3;

x.AB.NaV.add('IntegralController','tau_m',666,'tau_g',tau_g);
x.AB.CaT.add('IntegralController','tau_m',55555,'tau_g',tau_g);
x.AB.CaS.add('IntegralController','tau_m',45454,'tau_g',tau_g);
x.AB.ACurrent.add('IntegralController','tau_m',5000,'tau_g',tau_g);
x.AB.KCa.add('IntegralController','tau_m',1250,'tau_g',tau_g);
x.AB.Kd.add('IntegralController','tau_m',2000,'tau_g',tau_g);
x.AB.HCurrent.add('IntegralController','tau_m',125000,'tau_g',tau_g);


x.t_end = 5e5;
x.sim_dt = .1;
x.dt = 100;
[~,~,C] = x.integrate;

%% Make Figure

fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax

% cartoon cell
ax(1) = subplot(3,5,1);
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
