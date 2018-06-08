%% Figure 3: Creating and Implementing a Network

% set up xolotl object
% conversion from Prinz to phi

clear x


x = xolotl;

C = {'NaV','CaT','CaS','ACurrent','KCa'...
    ,'Kd','HCurrent'};
g(:,3) = [1000 24  20 500  0   1250 .5];
g(:,2) = [1000 0   40 200  0   250  .5];
g(:,1) = [1000 25  60 500  50  1000 .1];

x.add('AB','compartment','vol',.0628,'phi',906);
x.add('LP','compartment','vol',.0628,'phi',906);
x.add('PY','compartment','vol',.0628,'phi',906);

compartments = x.find('compartment');
for j = 1:length(compartments)
	for i = 1:length(C)
		x.(compartments{j}).add(...
      ['prinz/' C{i}],'gbar',g(i,j));
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

%% Make Figure

fig = figure('outerposition',[0 0 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax

% cartoon cell
ax(1) = subplot(3,5,1);
% xolotl structure
ax(2) = subplot(3,5,6);
% xolotl printout
ax(3) = subplot(3,5,11);
% voltage trace
ax(4) = subplot(4,5,2:5); hold on;
ax(5) = subplot(4,5,7:10); hold on;
ax(6) = subplot(4,5,12:15); hold on;
% synaptic currents
ax(7) = subplot(4,5,17:20); hold on;

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
	set(ax(ii+3), 'XTickLabel', [])
	ylabel(ax(ii+3), ['V_{' nameComps{ii} '} (mV)'])
	xlim(ax(ii+3), [0 max(time)]);
end

% plot the synaptic currents
c = lines(10);
plot(ax(7), time, synaptic_currents(:,1));

xlabel(ax(7), 'time (s)')
ylabel(ax(7), 'I_{syn} (nA)')
set(ax(7), 'YScale', 'log','YLim',[1e-1 1e2])
xlim(ax(7), [0 max(time)]);


%% Post-Processing

prettyFig('fs', 12, 'lw', 1)

% set the positions of the axes
pos = [ ...
     0.13       0.7127       0.1237       0.2123;
     0.13       0.4131       0.1237       0.2123;
     0.13       0.1134       0.1237       0.2123;
   0.3812       0.7932       0.4736       0.1577;
   0.3812       0.5741       0.4736       0.1577;
   0.3812        0.355       0.4736       0.1577;
   0.3812       0.1359       0.4736       0.1577];
for ii = 1:length(ax)
	ax(ii).Position = pos(ii, :);
end

% remove boxes
for ii = 1:length(ax)
  box(ax(ii), 'off')
end

% label the subplots
% labelFigure('capitalise', true)


return
% split the axes for aesthetics
deintersectAxes(ax(4:7))
