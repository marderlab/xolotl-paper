%% Figure 1: Minimal Code, Maximal Output

% set up xolotl object
% with Hodgkin-Huxley type dynamics
x     = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);


% get voltage trace
x.t_end = 0.2e3;

%% Make Figure

fig = figure('outerposition',[0 0 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax;

% cartoon cell
ax(1) = subplot(3,3,1);
% xolotl structure
ax(2) = subplot(3,3,2);
% xolotl readout from MATLAB
ax(3) = subplot(3,3,3);
% voltage trace
ax(4) = subplot(3,2,3); hold on;
% FI curve
ax(5) = subplot(3,2,4);
% activation and inactivation functions
for ii = 6:9
  ax(ii) = subplot(3,4,ii+3); hold on;
end

%% Make Cartoon Cell

image(ax(1), imread('figure_HH_cartoon.png'))
axis(ax(1), 'off');
ax(1).Tag = 'cartoon';

%% Make Xolotl Structure

image(ax(2), imread('figure_HH_code_snippet.png'))
axis(ax(2), 'off')
ax(1).Tag = 'code_snippet';

%% Make Xolotl Readout from MATLAB

image(ax(3), imread('figure_HH_xolotl_printout.png'))
axis(ax(3), 'off')
ax(1).Tag = 'xolotl_printout';

%% Make Voltage Trace

c           = lines(100);
nameComps   = x.find('compartment');
nComps      = length(nameComps);

% integrate and obtain the current traces
[V, Ca, ~, currents]  = x.integrate(0.1);
time                  = 1e-3 * x.dt * (1:length(V));

a = 1;
for ii = 1:nComps
  nameConds   = x.(nameComps{ii}).find('conductance');

  % process the voltage
  this_V      = V(:,ii);
  z           = a + length(nameConds) - 1;
  this_I      = currents(:,a:z);
  a           = z + 1;
  curr_index  = x.contributingCurrents(this_V, this_I);

  % plot the voltage
  for qq = 1:size(this_I, 2)
    Vplot = this_V;
    Vplot(curr_index ~= qq) = NaN;
    plot(ax(ii+3), time, Vplot, 'Color', c(qq,:), 'LineWidth', 3);
    xlabel(ax(ii+3), 'time (s)')
    ylabel(ax(ii+3), ['V_{ ' comp_names{ii} '} (mV)'])
  end
end

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
plot(ax(5), all_I_ext, all_f, '-ok')
xlabel(ax(5), 'applied current (nA)')
ylabel(ax(5), 'frequency (Hz)')

% set up tags
ax(5).Tag = 'FI_curve';

%% Make Activation and Inactivation Functions

conductance = x.HH.find('conductance');
% set up a voltage vector
V = linspace(-100, 100, 1000);
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
  plot(ax(6),   V,  minf,   'LineWidth', 3);
  plot(ax(7),   V,  hinf,   'LineWidth', 3);
  plot(ax(8),   V,  taum,   'LineWidth', 3);
  plot(ax(9),   V,  tauh,   'LineWidth', 3);
end

% set the tags
ax(6).Tag   = 'm_inf';
ax(7).Tag   = 'h_inf';
ax(8).Tag   = 'tau_m';
ax(9).Tag   = 'tau_h';

% set the xlabels and ylabels
ylabel(ax(6), 'm_{inf}')
xlabel(ax(6), 'V (mV)')

xlabel(ax(7), 'V (mV)')
ylabel(ax(7), 'h_{inf}')

ylabel(ax(8), 'tau_{m} (ms)')
xlabel(ax(8), 'V (mV)')
set(ax(8),    'YScale','log')

ylabel(ax(9), 'tau_{h} (ms)')
xlabel(ax(9), 'V (mV)')
set(ax(9),    'YScale','log')

%% Post-Processing

labelFigure('capitalise', true)
prettyFig()

for ii = 1:length(ax)
  box(ax(ii), 'off')
end
