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
ax(4) = subplot(2,4,2); hold on;
% voltage vs. time for stepped voltage
ax(5) = subplot(2,4,6); hold on;
% current vs. voltage
ax(6) = subplot(2,4,3);
% conductance vs. voltage
ax(7) = subplot(2,4,7);
% steady-state vs. voltage
ax(8) = subplot(2,4,4);
% R^2 fit
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
current 		= NaN(x.t_end/x.dt, length(Vsteps));
voltage 		= NaN(x.t_end/x.dt, length(Vsteps));
time 				= x.dt * (1:length(current));

% compute current vs. time over voltage steps
for ii = 1:length(Vsteps)
	% let the current reach steady-state
	x.t_end = 5e2;
	x.integrate([], Vhold);
	% save the current at this initial state
	x.t_end = 1e2;
	c1 = x.integrate([], Vhold);
	v1 = Vhold * ones(length(c1), 1);
	% perform the voltage step
	x.t_end = 4e2;
	c2 = x.integrate([], Vsteps(ii));
	v2 = Vsteps(ii) * ones(length(c2), 1);
	% clean up simulation artifact
	% c2(1) = c1(end);
	ctrace = [c1; c2];
	% store the current
	current(:, ii) = ctrace(:);
	% store the voltage
	voltage(:, ii) = [v1; v2];
end

%% Plot Current vs. Time over Voltage Steps

c = parula(floor(1.1*length(Vsteps)));
for ii = 1:length(Vsteps)
	plot(ax(4), time, current(:, ii), 'Color', c(ii, :))
end

xlabel(ax(4), 'time (ms)')
ylabel(ax(4), 'current (nA)')
set(ax(4), 'XLim', [90 120], 'YLim', [1.5*min(vectorise(current)) 1.1*max(vectorise(current))])

%% Plot Voltage vs. Time over Voltage Steps

for ii = 1:length(Vsteps)
	plot(ax(5), time, voltage(:, ii), 'Color', c(ii, :));
end

xlabel(ax(5), 'time (ms)')
ylabel(ax(5), 'voltage (mV)')
set(ax(5), 'XLim', [90 120], 'YLim', [-90 60], 'YTick', [-80 -40 0 40]);

%% Plot Current vs. Voltage

plot(ax(6), Vsteps, current(end,:), 'k')
xlabel(ax(6), 'voltage clamp (mV)')
ylabel(ax(6), 'current (nA)')
set(ax(6), 'XLim', [min(Vsteps) max(Vsteps)], 'XTick', [-80 -40 0 40])

%% Plot Conductance vs. Voltage
conductance = current(end, :) ./ (Vsteps - x.AB.Kd.E) / x.AB.A;
plot(ax(7), Vsteps, conductance, 'k');
xlabel(ax(7), 'voltage clamp (mV)')
ylabel(ax(7), 'ḡ (μS/mm^2)')
set(ax(7), 'XLim', [min(Vsteps) max(Vsteps)], 'XTick', [-80 -40 0 40])

%% Plot Steady-State Kd Activation Gating Variable

minf_func = x.getGatingFunctions('Kd');
for ii = 1:length(Vsteps)
	minf(ii) = minf_func(Vsteps(ii));
end
plot(ax(8), Vsteps, minf.^4, 'k')
xlabel(ax(8), 'voltage clamp (mV)')
set(ax(8), 'XLim', [min(Vsteps) max(Vsteps)], 'XTick', [-80 -40 0 40])

%% Plot R^2 value

% all_n 		= 1:4;
% all_r2 		= Inf*all_n;
% warning off
% for j = 1:4
% 	temp = conductance.^(1/j);
% 	rm_this = isnan(temp) | isinf(temp);
% 	all_r2(j) = rsquare(temp(~rm_this),minf(~rm_this));
% end
% warning on
%
% [maxr2,idx] = max(all_r2);
% fprintf(['[Best fit with n = ' oval(idx) ', r2 = ' oval(maxr2) ']']);
%
% plot(ax(9), all_n, 1-all_r2, 'k')
% xlabel(ax(9), 'exponent')
% ylabel(ax(9), 'R^2 error')

%% Post-Processing

prettyFig('fs', 12, 'lw', 1)

for ii = 1:length(ax)
  box(ax(ii), 'off')
end

pos = [ ...
	0.1300    0.7103    0.1566    0.2147;
	0.1300    0.4106    0.1566    0.2147;
	0.1300    0.1110    0.1566    0.2147;
	0.3572    0.6237    0.1566    0.3412;
	0.3572    0.1498    0.1566    0.3412;
	0.5953    0.6237    0.1566    0.3412;
	0.5953    0.1498    0.1566    0.3412;
	0.8191    0.6237    0.1566    0.3412;
	0.8191    0.1498    0.1566    0.3412];
for ii = 1:length(ax)
	ax(ii).Position = pos(ii,:);
end

% label the subplots
labelFigure('capitalise', true)

% split the axes for aesthetics
deintersectAxes(ax(4:9))
