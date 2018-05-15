%% Figure 3: Creating and Implementing a Network

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

fig = figure('outerposition',[0 0 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax

% cartoon cell
ax(1) = subplot(3,3,1);
% xolotl structure
ax(2) = subplot(3,3,2);
% xolotl printout
ax(3) = subplot(3,3,3);
% current vs. time
ax(4) = subplot(3,2,3); hold on;
% steady-state current vs. voltage
ax(5) = subplot(3,2,4); hold on;
% gating variables and time constants
ax(6) = subplot(3,4,9); hold on;
ax(7) = subplot(3,4,10); hold on;
ax(8) = subplot(3,4,11); hold on;
ax(9) = subplot(3,4,12); hold on;

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

%% Make Voltage Clamp

holding_V = -60;
all_V_step = linspace(-80,50,30);
all_I = NaN(x.t_end/x.dt,length(all_V_step));

x.integrate([],holding_V);
x.closed_loop = false;

for i = 1:length(all_V_step)
	all_I(:,i) = x.integrate([],all_V_step(i));
end

time = (1:length(all_I))*x.dt;

c = parula(length(all_V_step));
for i = 1:length(all_V_step)
	plot(ax(4), time, all_I(:,i), 'Color', c(i,:))
end
xlabel(ax(4), 'time (ms)')
ylabel(ax(4), 'current (nA)')
set(ax(4), 'XScale', 'log')

plot(ax(5), all_V_step, all_I(end,:), 'r')
xlabel(ax(5), 'voltage step (mV)')
ylabel(ax(5), 'current (nA)')

%% Make Activation and Inactivation Functions

conductance = x.AB.find('conductance');
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
  plot(ax(8),  	V,  taum,   'LineWidth', 3);
  plot(ax(9),  	V,  tauh,   'LineWidth', 3);
end

% set the tags
ax(6).Tag   = 'm_inf';
ax(7).Tag   = 'h_inf';
ax(8).Tag	  = 'tau_m';
ax(9).Tag  	= 'tau_h';

% set the xlabels and ylabels
ylabel(ax(6), 'm_{inf}')
xlabel(ax(6), 'V (mV)')

xlabel(ax(7), 'V (mV)')
ylabel(ax(7), 'h_{inf}')

ylabel(ax(8),	'tau_{m} (ms)')
xlabel(ax(8),	'V (mV)')
set(ax(8),    'YScale','log')

ylabel(ax(9),	'tau_{h} (ms)')
xlabel(ax(9),	'V (mV)')
set(ax(9),    'YScale','log')

%% Post-Processing

prettyFig()
labelFigure('capitalise', true) % this doesn't work

for ii = 1:length(ax)
  box(ax(ii), 'off')
end
