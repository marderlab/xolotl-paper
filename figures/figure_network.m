%% Figure 3: Creating and Implementing a Network

% set up xolotl object
% conversion from Prinz to phi
A = 0.0628;
vol = A; % this can be anything, doesn't matter
f = 14.96; % uM/nA
tau_Ca = 200;
phi = (2*f*96485*vol)/tau_Ca;

channels = {'NaV','CaT','CaS','ACurrent','KCa','Kd','HCurrent'};
prefix = 'prinz/';
gbar(:,1) = [1000 25  60 500  50  1000 .1];
gbar(:,2) = [1000 0   40 200  0   250  .5];
gbar(:,3) = [1000 24  20 500  0   1250 .5];
E =         [50   30  30 -80 -80 -80   -20];

x = xolotl;

x.add('AB','compartment','Cm',10,'A',A,'vol',vol,'phi',phi,'Ca_out',3000,'Ca_in',0.05,'tau_Ca',tau_Ca);
x.add('LP','compartment','Cm',10,'A',0.0628,'vol',vol,'phi',phi,'Ca_out',3000,'Ca_in',0.05,'tau_Ca',tau_Ca);
x.add('PY','compartment','Cm',10,'A',A,'vol',vol,'phi',phi,'Ca_out',3000,'Ca_in',0.05,'tau_Ca',tau_Ca);

compartments = x.find('compartment');
for j = 1:length(compartments)
	for i = 1:length(channels)
		x.(compartments{j}).add([prefix channels{i}],'gbar',gbar(i,j),'E',E(i));
	end
end

x.LP.add('Leak','gbar',.3,'E',-50);
x.PY.add('Leak','gbar',.1,'E',-50);


% set up synapses as in Fig. 2e
x.connect('AB','LP','Chol','gbar',30);
x.connect('AB','PY','Chol','gbar',3);
x.connect('AB','LP','Glut','gbar',30);
x.connect('AB','PY','Glut','gbar',10);
x.connect('LP','PY','Glut','gbar',1);
x.connect('PY','LP','Glut','gbar',30);
x.connect('LP','AB','Glut','gbar',30);


x.t_end = 5e3;

x.transpile; x.compile;

%% Make Figure

fig = figure('outerposition',[0 0 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax

% cartoon cell
ax(1) = subplot(5,3,1);
% xolotl structure
ax(2) = subplot(5,3,2);
% xolotl printout
ax(3) = subplot(5,3,3);
% voltage trace
ax(4) = subplot(5,1,2); hold on;
ax(5) = subplot(5,1,3); hold on;
ax(6) = subplot(5,1,4); hold on;
% synaptic currents
ax(7) = subplot(5,1,5); hold on;

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

%% Make Voltage Trace

c           = lines(100);
nameComps   = x.find('compartment');
nComps      = length(nameComps);

% integrate and obtain the current traces
x.closed_loop = true;
x.integrate;
[V, Ca, ~, currents, synaptic_currents]  = x.integrate;
time        = 1e-3 * x.dt * (1:length(V));

% plot the voltage
for ii = 1:nComps
  plot(ax(ii+3), time, V(:,ii), 'k', 'LineWidth', 1)
end

% plot the synaptic currents
plot(ax(7), time, synaptic_currents);
xlabel(ax(7), 'time (s)')
ylabel(ax(7), 'I_{syn} (nA)')
legend({'AB→LP','AB→PY','AB→LP','AB→PY','LP→PY','PY→LP','LP→AB'}, 'Location', 'EastOutside');

%% Post-Processing

prettyFig()
labelFigure('capitalise', true) % this doesn't work

% set the length of the voltage trace axes
for ii = 4:6
  ax(ii).Position(3) = ax(7).Position(3);
end

% remove boxes
for ii = 1:length(ax)
  box(ax(ii), 'off')
end
