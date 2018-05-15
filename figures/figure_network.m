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

x.handles.fig = figure('outerposition',[0 0 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax

% cartoon cell
x.handles.ax(1) = subplot(5,3,1);
% xolotl structure
x.handles.ax(2) = subplot(5,3,2);
% xolotl printout
x.handles.ax(3) = subplot(5,3,3);
% voltage trace
x.handles.ax(4) = subplot(5,1,2); hold on;
x.handles.ax(5) = subplot(5,1,3); hold on;
x.handles.ax(6) = subplot(5,1,4); hold on;
% synaptic currents
x.handles.ax(7) = subplot(5,1,5); hold on;

%% Make Cartoon Cell

image(x.handles.ax(1), imread('figure_network_Prinz_2004.png'))
axis(x.handles.ax(1), 'off');
x.handles.ax(1).Tag = 'cartoon';

%% Make Xolotl Structure

image(x.handles.ax(2), imread('figure_network_diagram.png'))
axis(x.handles.ax(2), 'off')
x.handles.ax(1).Tag = 'code_snippet';

%% Make Xolotl Readout from MATLAB

image(x.handles.ax(3), imread('figure_HH_xolotl_printout.png'))
axis(x.handles.ax(3), 'off')
x.handles.ax(1).Tag = 'xolotl_printout';

%% Make Voltage Trace

c           = lines(100);
nameComps   = x.find('compartment');
nComps      = length(nameComps);

% integrate and obtain the current traces
x.closed_loop = true;
x.integrate;
[V, Ca, ~, currents, synaptic_currents]  = x.integrate;
time        = 1e-3 * x.dt * (1:length(V));

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
    plot(x.handles.ax(ii+3), time, Vplot, 'Color', c(qq,:), 'LineWidth', 3);
    % xlabel(x.handles.ax(ii+3), 'time (s)')
    ylabel(x.handles.ax(ii+3), ['V_{ ' comp_names{ii} '} (mV)'])
  end
end
leg = legend(x.handles.ax(4), x.(nameComps{ii}).find('conductance'), 'Location', 'EastOutside');

% plot the synaptic currents
plot(x.handles.ax(7), time, synaptic_currents);
xlabel(x.handles.ax(7), 'time (s)')
ylabel(x.handles.ax(7), 'I_{syn} (nA)')
legend({'AB→LP','AB→PY','AB→LP','AB→PY','LP→PY','PY→LP','LP→AB'}, 'Location', 'EastOutside');

%% Post-Processing

prettyFig()
labelFigure('capitalise', true) % this doesn't work

for ii = 1:length(ax)
  box(ax(ii), 'off')
end
