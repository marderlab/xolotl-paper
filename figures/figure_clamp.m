%% Figure 5: Voltage Clamp

% set up xolotl object
vol = 0.0628; % this can be anything, doesn't matter
f = 1.496; % uM/nA
tau_Ca = 200;
F = 96485; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;
Ca_target = 0; % used only when we add in homeostatic control

x = xolotl;
x.add('AB','compartment','Cm',10,'A',0.0628,'vol',vol,'phi',phi,'Ca_out',3000,'Ca_in',0.05,'tau_Ca',tau_Ca,'Ca_target',Ca_target);

x.AB.add('liu-approx/NaV','gbar',@() 115/x.AB.A,'E',30);
x.AB.add('liu-approx/CaT','gbar',@() 1.44/x.AB.A,'E',30);
x.AB.add('liu-approx/Kd','gbar',@() 38.31/x.AB.A,'E',-80);
x.AB.add('Leak','gbar',@() 0.0622/x.AB.A,'E',-50);

holding_V = -60;
all_V_step = linspace(-80,50,30);

x.t_end = 5e2;
x.sim_dt = .1;
x.dt = .1;

%% Make Figure

fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax

% cartoon cell
ax(1) = subplot(2,3,1);
% xolotl structure
ax(2) = subplot(2,3,2);
% xolotl printout
ax(3) = subplot(2,3,3);
% voltage vs. time
ax(4) = subplot(2,3,4); hold on;
% current vs. time
ax(5) = subplot(2,3,5); hold on;
% steady-state current vs. voltage
ax(6) = subplot(2,3,6); hold on;

%% Make Cartoon Cell

image(ax(1), imread('figure_network_Prinz_2004.png'))
axis(ax(1), 'off');
ax(1).Tag = 'cartoon';

%% Make Xolotl Structure

image(ax(2), imread('figure_network_diagram.png'))
axis(ax(2), 'off')
ax(1).Tag = 'code_snippet';

%% Make Xolotl Readout from MATLAB

image(ax(3), imread('figure_HH_xolotl_printout.png'))
axis(ax(3), 'off')
ax(1).Tag = 'xolotl_printout';

%% Set Up Voltage Clamp

holding_V = -60;
all_V_step = linspace(-80,50,30);
all_I = NaN(x.t_end/x.dt,length(all_V_step));

x.integrate([],holding_V);
x.closed_loop = false;

for i = 1:length(all_V_step)
	all_I(:,i) = x.integrate([],all_V_step(i));
end

time = (1:length(all_I))*x.dt;

%% Plot Voltage vs. Time

c = parula(length(all_V_step));
for ii = 1:length(all_V_step)
	Vstep = all_V_step(ii)*ones(length(time),1);
	plot(ax(4), time, Vstep, 'Color', c(ii, :));
end
xlabel(ax(4), 'time (ms)')
ylabel(ax(4), 'voltage clamp (mV)')

%% Plot Current vs. Time

for i = 1:length(all_V_step)
	plot(ax(5), time, all_I(:,i), 'Color', c(i,:))
end
xlabel(ax(5), 'time (ms)')
ylabel(ax(5), 'current (nA)')
set(ax(5), 'XScale', 'log', 'XLim', [1e-2 1e1], 'XTick', [1e-2 1e-1 1e0 1e1])

%% Plot Current vs. Voltage

plot(ax(6), all_V_step, all_I(end,:), 'r')
xlabel(ax(6), 'voltage clamp (mV)')
ylabel(ax(6), 'current (nA)')

%% Post-Processing

prettyFig()

for ii = 1:length(ax)
  box(ax(ii), 'off')
end

pos = [ ...
	0.1580    0.6000    0.1722    0.3048;
	0.4826    0.6000    0.1722    0.3048;
	0.8038    0.6000    0.1722    0.3048;
	0.1580    0.2101    0.1722    0.3048;
	0.4826    0.2101    0.1722    0.3048;
	0.8038    0.2101    0.1722    0.3048];
for ii = 1:length(ax)
	ax(ii).Position = pos(ii,:);
end

% label the subplots
labelFigure('capitalise', true)

% split the axes for aesthetics
deintersectAxes(ax(4:6))
