%% Figure 1: Minimal Code, Maximal Output

% set up xolotl object
% with Hodgkin-Huxley type dynamics
clearvars
x = xolotl;


x.add('compartment','HH', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);

%% Make Figure

fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;
c = lines;
clear ax;


% xolotl readout from MATLAB
ax(3) = subplot(3,5,11);
% voltage trace
ax(4) = subplot(4,5,2:3); hold on;
% injected current
ax(5) = subplot(4,5,7:8);
% FI curve
ax(6) = subplot(2,5,4:5);
% activation and inactivation functions
for ii = 1:4
  ax(ii+6) = subplot(2,5,ii+6); hold on;
end

%% Make Cartoon Cell
showImageInAxes(ax(3),imread('fig_HH.png'))


% integrate and obtain the current traces
dt = .1;
x.dt = dt;
x.sim_dt = dt;
x.t_end = 1.5e2;
x.I_ext = [zeros(50/dt,1); .2*ones(100/dt,1)];

[V, ~, ~, I]  = x.integrate;
time = 1e-3 * x.dt * (1:length(V));

curr_index  = x.contributingCurrents(V, I);

% plot the voltage
for qq = 1:size(I, 2)
	Vplot = V;
	Vplot(curr_index ~= qq) = NaN;
	plot(ax(4), time, Vplot, 'Color', c(qq,:));
  l(qq) = plot(ax(4),NaN,NaN,'o','MarkerFaceColor',c(qq,:),'MarkerEdgeColor',c(qq,:));
end
lh = legend(l, x.HH.find('conductance'),'Location','northwest');

ylabel(ax(4), ['V_m (mV)'])
set(ax(4), 'XTick', [], 'XLim', [0 x.t_end/1e3], 'YLim', [-80 30], 'XColor', [1 1 1])

% plot the current step
plot(ax(5), time, x.I_ext,'k')
xlabel(ax(5), 'time (s)')
ylabel(ax(5), 'I_{ext} (nA)')
set(ax(5), 'XLim', [0 (x.t_end+10)/1e3], 'YLim', [-0.1 0.3], 'XTick', [0 0.05 0.1 0.15])

%% Make FI Curve
all_I_ext = linspace(-0.1,1,50);
all_f = NaN*all_I_ext;

% find the frequency of a tonically-spiking neuron
x.t_end = 5e3;
for i = 1:length(all_I_ext)
  x.I_ext = all_I_ext(i);
  V = x.integrate;
  all_f(i) = length(computeOnsOffs(V>0))/(x.t_end*1e-3);
end


% plot on the correct axes
plot(ax(6), all_I_ext, all_f, '-k')
xlabel(ax(6), 'Injected current (nA)')
ylabel(ax(6), 'Firing rate (Hz)')
set(ax(6), 'XLim', [min(all_I_ext)*1.1 max(all_I_ext)*1.05], 'XTick', [0 0.5 1])


%% Make Activation and Inactivation Functions

conductance = x.HH.find('conductance');
% set up a voltage vector
V = linspace(-80, 84, 1000);
% set calcium to default value
Ca = 3e3;
% evaluate the functions
minf = NaN*V;
hinf = NaN*V;
taum = NaN*V;
tauh = NaN*V;
for ii = 1:length(conductance)

  % get the functions to plot
  [m_inf, h_inf, tau_m, tau_h] = x.getGatingFunctions(conductance{ii});

  % evaluate the functions
  for qq = 1:length(V)
    if nargin(m_inf) == 1
      minf(qq) = m_inf(V(qq));
    else
      minf(qq) = m_inf(V(qq),Ca);
    end
    if nargin(h_inf) == 1
      hinf(qq) = h_inf(V(qq));
    else
      hinf(qq) = h_inf(V(qq),Ca);
    end

    taum(qq) = tau_m(V(qq));
    tauh(qq) = tau_h(V(qq));
  end

  % plot onto the correct axes
  plot(ax(7),   V,  minf,'Color',c(ii,:));
  plot(ax(9),   V,  taum,'Color',c(ii,:));
  if ii == 3
    plot(ax(8),   V,  hinf,'Color',c(ii,:));
    plot(ax(10),  V,  tauh,'Color',c(ii,:));
  end
end


% set the xlabels and ylabels
ylabel(ax(7), 'm_{\infty}')
xlabel(ax(7), 'V (mV)')
set(ax(7), 'YLim', [0 1]);

xlabel(ax(8), 'V (mV)')
ylabel(ax(8), 'h_{\infty}')
set(ax(8), 'YLim', [0 1]);

ylabel(ax(9), '\tau_m (ms)')
xlabel(ax(9), 'V (mV)')
set(ax(9),    'YScale','log', 'YTick', [10^-2 10^0 10^2], 'YLim', [10^-2 10^2])

ylabel(ax(10),'\tau_h (ms)')
xlabel(ax(10),'V (mV)')
set(ax(10),   'YScale','log', 'YTick', [10^-2 10^0 10^2], 'YLim', [10^-2 10^2])

for ii = 1:4
  set(ax(ii+6), 'XTick', [-80, -40, 0, 40, 80])
end

%% Post-Processing
% beautify
prettyFig('fs', 16, 'plw', 2,'lw',1,'tick_length',5)

% remove boxes around subplots
for ii = 3:length(ax)
  box(ax(ii), 'off')
end

% fix the sizing and spacing
pos = [...
  0.0100    0.7093    0.1174    0.2157;
  0.0100    0.4096    0.1174    0.2157;
  0.0100    0.15      0.25      0.75;
  0.3300    0.7988    0.2866    0.1577;
  0.3300    0.6153    0.2866    0.1577;
  0.7       0.6153    0.26    0.3412;
  0.3300    0.1646    0.11      0.2474;
  0.5045    0.1646    0.11      0.2474;
  0.6753    0.1646    0.11      0.2474;
  0.8595    0.1646    0.11      0.2474];

for ii = 3:length(ax)
  ax(ii).Position = pos(ii, :);
end



% label the subplots
lax(2)=labelAxes(ax(4),'D','x_offset',-.05,'y_offset',-.025,'font_size',18);
lax(3)=labelAxes(ax(6),'E','x_offset',-.04,'y_offset',-.025,'font_size',18);
lax(4)=labelAxes(ax(7),'F','x_offset',-.03,'y_offset',-.025,'font_size',18);
lax(5)=labelAxes(ax(8),'G','x_offset',-.03,'y_offset',-.025,'font_size',18);
lax(6)=labelAxes(ax(9),'H','x_offset',-.03,'y_offset',-.025,'font_size',18);
lax(7)=labelAxes(ax(10),'I','x_offset',-.03,'y_offset',-.025,'font_size',18);

ax(3).Units = 'pixels';
ax(3).Position = [1   70  324 435];

lh.Position = [.33 .85 .063 .12];

ax(4).YLim = [-80 40];
ax(4).YTick = -80:40:40;
ax(5).YTick = [0 .2];

ax(6).YLim = [-5 100];

seperateAxes(ax(7:10));
seperateAxes(ax(6),'mask_x',false);
seperateAxes(ax(4:5));