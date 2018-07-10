%% Figure 5: Voltage Clamp

% set up xolotl object
close all
x = xolotl;
x.add('compartment','AB','A',.06)
x.AB.add('Kd','gbar', 300);

holding_V = -60;
all_V_step = linspace(-80,50,30);

x.t_end = 5e2;
x.sim_dt = .1;
x.dt = .1;

%% Make Figure

fig = figure('outerposition',[0 0 1200 1201],'PaperUnits','points','PaperSize',[1200 1201]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax
ax.cartoon = subplot(3,3,1); hold on
ax.code =  subplot(3,3,2); hold on
ax.V =  subplot(3,3,4); hold on
ax.I =  subplot(3,3,5); hold on
ax.max_I =  subplot(3,3,6); hold on
ax.g =  subplot(3,3,7); hold on
ax.m_inf =  subplot(3,3,8); hold on
ax.r2 =  subplot(3,3,9); hold on



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
	plot(ax.I, time, I(:, ii), 'Color', c(ii, :))
end

xlabel(ax.I, 'time (ms)')
ylabel(ax.I, 'Injected current (nA)')
set(ax.I, 'XLim', [0 50], 'YLim', [1.5*min(vectorise(I)) 1.1*max(vectorise(I))])

%% Plot Voltage vs. Time over Voltage Steps

for ii = 1:length(all_V_step)
	plot(ax.V, time, V(:, ii), 'Color', c(ii, :));
end

xlabel(ax.V, 'time (ms)')
ylabel(ax.V, 'Clamped voltage (mV)')
set(ax.V, 'XLim', [0 50], 'YLim', [-90 60], 'YTick', [-80 -40 0 40]);

%% Plot Current vs. Voltage

plot(ax.max_I, all_V_step, I(end,:), 'k')
xlabel(ax.max_I, 'Clamped voltage (mV)')
ylabel(ax.max_I, 'Clamped current (nA)')
set(ax.max_I, 'XLim', [min(all_V_step) max(all_V_step)], 'XTick', [-80 -40 0 40])

%% Plot Conductance vs. Voltage
conductance = I(end, :) ./ (all_V_step - x.AB.Kd.E) / x.AB.A;
plot(ax.g, all_V_step, conductance, 'k');
xlabel(ax.g, 'Clamped voltage (mV)')
ylabel(ax.g, 'Conductance (\muS/mm^2)')
set(ax.g, 'XLim', [min(all_V_step) max(all_V_step)], 'XTick', [-80 -40 0 40],'YLim',[0 300])

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

clear hplot
for ii = 1:length(all_n)
	plot(ax.m_inf, all_V_step, minf.^all_n(ii), 'Color', c(ii, :))
	hplot(ii) = plot(ax.m_inf, NaN, NaN, 'o', 'MarkerFaceColor', c(ii, :), 'MarkerEdgeColor', c(ii, :), 'MarkerSize', 8);
end
plot(ax.m_inf, all_V_step, conductance/conductance(end), 'ok')
hplot(end+1) = plot(ax.m_inf, NaN, NaN, 'o', 'MarkerEdgeColor', [0 0 0], 'MarkerSize', 8);
xlabel(ax.m_inf, 'clamped V (mV)')
ylabel(ax.m_inf, 'm_\infty')
set(ax.m_inf, 'XLim', [min(all_V_step) max(all_V_step)], 'XTick', [-80 -40 0 40])
lh = legend(hplot, {'n = 1', 'n = 2', 'n = 3', 'n = 4', 'data'}, 'Location', 'NorthWest');
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

plot(ax.r2, all_n, 1-all_r2, 'k')
xlabel(ax.r2, 'exponent')
ylabel(ax.r2, '1 - r^2')
set(ax.r2, 'XLim', [0.5 6.5], 'XTick', 1:6)

%% Post-Processing

prettyFig('fs', 18, 'lw', 1.5,'plw',2)



showImageInAxes(ax.cartoon,imread('clamp_cartoon.png'))

showImageInAxes(ax.code,imread('clamp_code.png'))

ax.code.Position = [ 0.5500    0.600    0.3346    0.3474];
ax.cartoon.Position = [ 0.1000    0.6000    0.3346    0.3474];


movePlot(ax.V,'left',.03)
movePlot(ax.g,'left',.03)


movePlot(ax.max_I,'right',.03)
movePlot(ax.r2,'right',.03)

% label the subplots
labelAxes(ax.cartoon,'A','x_offset',-.01,'y_offset',-.13,'font_size',24);
labelAxes(ax.code,'B','x_offset',-.02,'y_offset',-.1,'font_size',24);
labelAxes(ax.V,'C','x_offset',-.03,'y_offset',-.022,'font_size',24);
labelAxes(ax.I,'D','x_offset',-.035,'y_offset',-.025,'font_size',24);
labelAxes(ax.max_I,'E','x_offset',-.03,'y_offset',-.025,'font_size',24);
labelAxes(ax.g,'F','x_offset',-.03,'y_offset',-.02,'font_size',24);
labelAxes(ax.m_inf,'G','x_offset',-.03,'y_offset',-.025,'font_size',24);
labelAxes(ax.r2,'H','x_offset',-.035,'y_offset',-.025,'font_size',24);

deintersectAxes(ax.V)
deintersectAxes(ax.I)
deintersectAxes(ax.max_I)
deintersectAxes(ax.g)
deintersectAxes(ax.m_inf)
deintersectAxes(ax.r2)