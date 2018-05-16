%% Figure 5: Voltage Clamp

% set up xolotl object
x = xolotl;
x.add('AB','compartment','Cm',10,'A',0.0628)

% x.AB.add('liu/NaV','gbar', 1000,'E', 30);
x.AB.add('liu/Kd','gbar', 300,'E', -80);
% x.AB.add('Leak','gbar', 1,'E', -50);

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
ax(1) = subplot(3,4,1);
% xolotl structure
ax(2) = subplot(3,4,5);
% code snipped
ax(3) = subplot(3,4,9);
% current vs. time for stepped voltage
ax(4) = subplot(2,4,2);
% voltage vs. time for stepped voltage
ax(5) = subplot(2,4,6);
% current vs. voltage
ax(6) = subplot(2,4,3);
% conductance vs. voltage
ax(7) = subplot(2,4,7);
% R^2 fit
ax(8) = subplot(2,4,4);
% steady-state vs. voltage
ax(9) = subplot(2,4,8);

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

x.closed_loop = true;
Vhold				= -60;
Vsteps 			= linspace(-80, 50, 30);
current 		= NaN(2 * x.t_end/x.dt, length(Vsteps));

for ii = 1:length(Vsteps)
	% let the current reach steady-state
	x.integrate([], Vhold);
	% save the current at this initial state
	c = x.integrate([], Vhold);
	% perform the voltage step
	ctrace 		= [c; x.integrate([], Vsteps(ii))];
	current(:, ii) = ctrace(:);
	% clean up simulation artifact
	current(x.t_end/x.dt + 1, ii) = current(x.t_end/x.dt, ii);
end

return

% perform the voltage steps

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

% pos = [ ...
% 	0.1580    0.6000    0.1722    0.3048;
% 	0.4826    0.6000    0.1722    0.3048;
% 	0.8038    0.6000    0.1722    0.3048;
% 	0.1580    0.2101    0.1722    0.3048;
% 	0.4826    0.2101    0.1722    0.3048;
% 	0.8038    0.2101    0.1722    0.3048];
% for ii = 1:length(ax)
% 	ax(ii).Position = pos(ii,:);
% end

% label the subplots
labelFigure('capitalise', true)

% split the axes for aesthetics
% deintersectAxes(ax(4:6))
