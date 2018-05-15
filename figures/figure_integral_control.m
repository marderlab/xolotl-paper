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
% voltage trace
ax(4) = subplot(3,1,2); hold on;
ax(5) = subplot(3,1,3); hold on;

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


%% Make Conductance Plots

time = x.dt*(1:length(C))*1e-3;
plot(ax(4), time, C(:,2:2:end));
set(ax(4), 'XScale', 'log', 'YScale','log', 'YTick', [1e-2 1e0 1e2 1e4])
ylabel(ax(4), 'ḡ (μS/mm^2')
leg = legend(ax(4), x.AB.find('conductance'), 'Location', 'EastOutside');

%% Make Voltage Plot

x.dt = .1;
x.t_end = 1e3;
V = x.integrate;
time = x.dt*(1:length(V))*1e-3;
plot(ax(5), time,V,'k', 'LineWidth', 1)
set(ax(5), 'YLim', [-80 50])
ylabel(ax(5), 'V_m (mV)')
xlabel(ax(5), 'time (s)')

%% Post-Processing

prettyFig()
labelFigure('capitalise', true) % this doesn't work

% set the length of the voltage trace axes
ax(5).Position(3) = ax(4).Position(3);


% remove boxes
for ii = 1:length(ax)
  box(ax(ii), 'off')
end
