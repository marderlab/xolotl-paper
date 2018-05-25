%% Figure 1: Minimal Code, Maximal Output

% set up xolotl object
% with Hodgkin-Huxley type dynamics
x     = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);

%% Make Figure

fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax;

% cartoon cell
ax(1) = subplot(3,5,1);
% xolotl structure
ax(2) = subplot(3,5,6);
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

image(ax(1), imread('paper-figs-0.png'))
axis(ax(1), 'off');
ax(1).Tag = 'cartoon';

%% Make Xolotl Structure

image(ax(2), imread('figure_HH_code_snippet.png'))
axis(ax(2), 'off')
ax(2).Tag = 'code_snippet';

%% Make Xolotl Readout from MATLAB

image(ax(3), imread('figure_HH_xolotl_printout.png'))
axis(ax(3), 'off')
ax(3).Tag = 'xolotl_printout';

%% Make Voltage Trace

a = 1;
c           = lines(100);
nameComps   = x.find('compartment');
nComps      = length(nameComps);
nameConds   = x.(nameComps{1}).find('conductance');

% integrate and obtain the current traces
x.t_end = 0.05e3;
x.closed_loop = true;
V0 = x.integrate(0.0);
time0 = 1e-3 * x.dt * (1:length(V0));

x.t_end = 0.1e3;
[V, Ca, ~, currents]  = x.integrate(0.2);
time                  = 1e-3 * x.dt * (1:length(V));

% process the voltage
this_V      = V(:,1);
z           = a + length(nameConds) - 1;
this_I      = currents(:,a:z);
a           = z + 1;
curr_index  = x.contributingCurrents(this_V, this_I);

% plot the voltage
plot(ax(4), time0, V0, 'k', 'LineWidth', 1.5)
for qq = 1:size(this_I, 2)
  Vplot = this_V;
  Vplot(curr_index ~= qq) = NaN;
  plot(ax(4), time + max(time0), Vplot, 'Color', c(qq,:), 'LineWidth', 1.5);
end

% xlabel(ax(4), 'time (s)')
ylabel(ax(4), ['V_m (mV)'])
set(ax(4), 'XTick', [], 'XLim', [0 x.t_end/1e3], 'YLim', [-80 30], 'XColor', [1 1 1])

% plot the current step
current = [zeros(length(time0), 1); 0.2*ones(length(time),1)];
plot(ax(5), [time0 time + max(time0)], current)
xlabel(ax(5), 'time (s)')
ylabel(ax(5), 'I_{ext} (nA)')
set(ax(5), 'XLim', [0 (x.t_end+10)/1e3], 'YLim', [-0.1 0.3], 'XTick', [0 0.05 0.1 0.15])

%% Make FI Curve

% set up vectors
all_I_ext = linspace(-0.1,1,50);
all_f = NaN*all_I_ext;

% find the frequency of a tonically-spiking neuron
x.t_end = 5e3;
for i = 1:length(all_I_ext)
	V = x.integrate(all_I_ext(i));
	all_f(i) = length(computeOnsOffs(V>0))/(x.t_end*1e-3);
end

% plot on the correct axes
plot(ax(6), all_I_ext, all_f, '-k')
xlabel(ax(6), 'applied current (nA)')
ylabel(ax(6), 'firing rate (Hz)')
set(ax(6), 'XLim', [min(all_I_ext)*1.1 max(all_I_ext)*1.05], 'XTick', [0 0.5 1])

% set up tags
ax(6).Tag = 'FI_curve';

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
  plot(ax(7),   V,  minf,   'LineWidth', 3);
  plot(ax(8),   V,  hinf,   'LineWidth', 3);
  plot(ax(9),   V,  taum,   'LineWidth', 3);
  plot(ax(10),  V,  tauh,   'LineWidth', 3);
end

% set the tags
ax(7).Tag   = 'm_∞';
ax(8).Tag   = 'h_∞';
ax(9).Tag   = 'τ_m';
ax(10).Tag  = 'τ_h';

% set the xlabels and ylabels
ylabel(ax(7), 'm_∞')
xlabel(ax(7), 'V (mV)')
set(ax(7), 'YLim', [0 1]);

xlabel(ax(8), 'V (mV)')
ylabel(ax(8), 'h_∞')
set(ax(8), 'YLim', [0 1]);

ylabel(ax(9), 'τ_m (ms)')
xlabel(ax(9), 'V (mV)')
set(ax(9),    'YScale','log', 'YTick', [10^-2 10^0 10^2], 'YLim', [10^-2 10^2])

ylabel(ax(10),'τ_h (ms)')
xlabel(ax(10),'V (mV)')
set(ax(10),   'YScale','log', 'YTick', [10^-2 10^0 10^2], 'YLim', [10^-2 10^2])

for ii = 1:4
  set(ax(ii+6), 'XTick', [-80, -40, 0, 40, 80])
end

%% Post-Processing

% beautify
prettyFig('fs', 12, 'lw', 1.5)

% remove boxes around subplots
for ii = 1:length(ax)
  box(ax(ii), 'off')
end

% fix the sizing and spacing
pos = [...
  0.0100    0.7093    0.1174    0.2157;
  0.0100    0.4096    0.1174    0.2157;
  0.0100    0.1100    0.1174    0.2157;
  0.3486    0.7988    0.2866    0.1577;
  0.3486    0.6153    0.2866    0.1577;
  0.7018    0.6153    0.2866    0.3412;
  0.3486    0.1646    0.1237    0.2474;
  0.5045    0.1646    0.1237    0.2474;
  0.6753    0.1646    0.1237    0.2474;
  0.8595    0.1646    0.1237    0.2474];

for ii = 1:length(ax)
  ax(ii).Position = pos(ii, :);
end

% label the subplots
% labelFigure('capitalise', true)

% deintersectAxes(ax(4:10))
