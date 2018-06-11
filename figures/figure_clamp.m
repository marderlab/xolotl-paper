%% Figure 5: Voltage Clamp

% set up xolotl object
clearvars
x = xolotl;
x.add('AB','compartment','A',.06)
x.AB.add('Kd','gbar', 300);

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
% code snippet
ax(3) = subplot(3,4,9);

% I vs. time for stepped V
ax(4) = subplot(2,4,2); hold on;
% V vs. time for stepped voltage
ax(5) = subplot(2,4,6); hold on;
% I vs. voltage
ax(6) = subplot(2,4,3);
% conductance vs. voltage
ax(7) = subplot(2,4,7);
% steady-state vs. voltage
ax(8) = subplot(2,4,4); hold on;
% R^2 fit
ax(9) = subplot(2,4,8);

%% Make Cartoon Cell

% image(ax(1), imread('figure_network_Prinz_2004.png'))
% axis(ax(1), 'off');
% ax(1).Tag = 'cartoon';

% %% Make Xolotl Structure

% image(ax(2), imread('figure_network_diagram.png'))
% axis(ax(2), 'off')
% ax(1).Tag = 'code_snippet';

% %% Make Xolotl Readout from MATLAB

% image(ax(3), imread('figure_HH_xolotl_printout.png'))
% axis(ax(3), 'off')
% ax(1).Tag = 'xolotl_printout';

%% Set Up Voltage Clamp
N = floor(x.t_end/x.sim_dt);
I 		= NaN(N, length(all_V_step));
V 		= NaN(N, length(all_V_step));
time = x.dt*(1:N);
x.V_clamp = repmat(holding_V,N,1);
x.integrate();
x.closed_loop = false;

% compute current vs. time over voltage steps
for i = 1:length(all_V_step)
	
	V_clamp = repmat(all_V_step(i),N,1);
	V_clamp(1:100) = holding_V;
	x.V_clamp = V_clamp;
	I(:,i) = x.integrate;
	V(:,i) = V_clamp;

end

%% Plot Current vs. Time over Voltage Steps

c = parula(floor(1.1*length(all_V_step)));
for ii = 1:length(all_V_step)
	plot(ax(5), time, I(:, ii), 'Color', c(ii, :))
end

xlabel(ax(5), 'time (ms)')
ylabel(ax(5), 'current (nA)')
set(ax(5), 'XLim', [0 50], 'YLim', [1.5*min(vectorise(I)) 1.1*max(vectorise(I))])

%% Plot Voltage vs. Time over Voltage Steps

for ii = 1:length(all_V_step)
	plot(ax(4), time, V(:, ii), 'Color', c(ii, :));
end

xlabel(ax(4), 'time (ms)')
ylabel(ax(4), 'Clamped voltage (mV)')
set(ax(4), 'XLim', [0 50], 'YLim', [-90 60], 'YTick', [-80 -40 0 40]);

%% Plot Current vs. Voltage

plot(ax(6), all_V_step, I(end,:), 'k')
xlabel(ax(6), 'Clamped voltage (mV)')
ylabel(ax(6), 'Clamped current (nA)')
set(ax(6), 'XLim', [min(all_V_step) max(all_V_step)], 'XTick', [-80 -40 0 40])

%% Plot Conductance vs. Voltage
conductance = I(end, :) ./ (all_V_step - x.AB.Kd.E) / x.AB.A;
plot(ax(7), all_V_step, conductance, 'k');
xlabel(ax(7), 'Clamped voltage (mV)')
ylabel(ax(7), 'Conductance (\muS/mm^2)')
set(ax(7), 'XLim', [min(all_V_step) max(all_V_step)], 'XTick', [-80 -40 0 40],'YLim',[0 300])

%% Plot Steady-State Kd Activation Gating Variable

all_n 		= 1:4;
all_r2 		= Inf*all_n;
c = lines;
minf_func = x.getGatingFunctions('Kd');

% compute the steady-state
for ii = 1:length(all_V_step)
	minf(ii) = minf_func(all_V_step(ii));
end
% plot the steady state at various powers

for ii = 1:length(all_n)
	plot(ax(8), all_V_step, minf.^all_n(ii), 'Color', c(ii, :))
	hplot(ii) = plot(ax(8), NaN, NaN, 'o', 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :), 'MarkerSize', 8);
end
plot(ax(8), all_V_step, conductance/conductance(end), 'ok')
hplot(end+1) = plot(ax(8), NaN, NaN, 'o', 'MarkerEdgeColor', [0 0 0], 'MarkerSize', 8);
xlabel(ax(8), 'clamped V (mV)')
ylabel(ax(8), 'm_\infty')
set(ax(8), 'XLim', [min(all_V_step) max(all_V_step)], 'XTick', [-80 -40 0 40])
legend(hplot, {'n = 1', 'n = 2', 'n = 3', 'n = 4', 'data'}, 'Location', 'EastOutside')
%% Plot R^2 value

warning off
all_n = linspace(1,6,16);
all_r2 = NaN*all_n;
for j = 1:length(all_n)
	n = all_n(j);
	temp = conductance.^(1/n);
	rm_this = isnan(temp) | isinf(temp);
	all_r2(j) = rsquare(temp(~rm_this),minf(~rm_this));
end
warning on

[maxr2,idx] = max(all_r2);

plot(ax(9), all_n, 1-all_r2, 'k')
xlabel(ax(9), 'exponent')
ylabel(ax(9), '1 - r^2')
set(ax(9), 'XLim', [0.5 6.5], 'XTick', 1:6)

%% Post-Processing

prettyFig('fs', 12, 'lw', 1)

for ii = 1:length(ax)
  box(ax(ii), 'off')
end

pos = [ ...
    0.0600    0.7103    0.1566    0.2147;
    0.0600    0.4106    0.1566    0.2147;
    0.0600    0.1110    0.1566    0.2147;
    0.2955    0.6237    0.1566    0.3412;
    0.2955    0.1301    0.1566    0.3412;
    0.5336    0.6237    0.1566    0.3412;
    0.5336    0.1301    0.1566    0.3412;
    0.7574    0.6237    0.1566    0.3412;
    0.7574    0.1301    0.1566    0.3412];
for ii = 1:length(ax)
	ax(ii).Position = pos(ii,:);
end

% label the subplots
% labelFigure('capitalise', true)

return

% split the axes for aesthetics
deintersectAxes(ax(4:9))
