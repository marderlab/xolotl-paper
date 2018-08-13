%% Figure 3: Creating and Implementing a Network

% set up xolotl object
% conversion from Prinz to phi

clear x g


x = xolotl;

C = {'NaV','CaT','CaS','ACurrent','KCa'...
    ,'Kd','HCurrent'};
g(:,3) = [1000 24  20 500  0   1250 .5];
g(:,2) = [1000 0   40 200  0   250  .5];
g(:,1) = [1000 25  60 500  50  1000 .1];

x.add('compartment','AB');
x.add('compartment','LP');
x.add('compartment','PY');

x.AB.add('CalciumMech1');
x.LP.add('CalciumMech1');
x.PY.add('CalciumMech1');

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

ax.network = subplot(4,5,1); hold on

ax.code = subplot(4,5,6);

% voltage traces
ax.AB = subplot(4,5,2:5); hold on;
ax.LP = subplot(4,5,7:10); hold on;
ax.PY = subplot(4,5,12:15); hold on;

% synaptic currents
ax.S = subplot(4,5,17:20); hold on;


%% Make Voltage Trace
comp_names   = x.find('compartment');


% integrate and obtain the current traces
x.closed_loop = true;
x.t_end = 4e3;
x.integrate;
[V, Ca, ~, ~, synaptic_currents]  = x.integrate;
time        = 1e-3 * x.dt * (1:length(V));

% plot the voltage
for i = 1:3
  plot(ax.(comp_names{i}), time, V(:,i), 'k')
	set(ax.(comp_names{i}), 'XTickLabel', [],'XLim',[0 max(time)],'YLim',[-80 50])
	ylabel(ax.(comp_names{i}), ['V_{' comp_names{i} '} (mV)'])
end

% plot the synaptic currents
synaptic_states = synaptic_currents(:,1:2:end);
synaptic_currents = synaptic_currents(:,2:2:end);
c = lines(10);
plot(ax.S, time, synaptic_states(:,6),'r');

xlabel(ax.S, 'Time (s)')
ylabel(ax.S, 's_{PY\rightarrowLP} ')
set(ax.S, 'YScale', 'linear','YLim',[0 1])
xlim(ax.S, [0 max(time)]);


%% Post-Processing

prettyFig('fs', 16, 'plw', 1.5,'lw',1.5)


% get some positions right
ax.AB.Position = [.45 .78 .5 .15];
ax.LP.Position = [.45 .57 .5 .15];
ax.PY.Position = [.45 .35 .5 .15];
ax.S.Position = [.45 .15 .5 .15];


showImageInAxes(ax.network,imread('network.png'))
showImageInAxes(ax.code,imread('network_code.png'))

ax.code.Position = [-0.0500    0.0500    0.5321    0.5964];
ax.network.Position = [.03 .67 .2566 .2872];

labelAxes(ax.network,'A','x_offset',0.04,'y_offset',-.1,'font_size',24);

labelAxes(ax.code,'B','x_offset',0.1,'y_offset',-.05,'font_size',24);

labelAxes(ax.AB,'C','x_offset',-0.05,'y_offset',-.05,'font_size',24);
labelAxes(ax.LP,'D','x_offset',-0.05,'y_offset',-.05,'font_size',24);
labelAxes(ax.PY,'E','x_offset',-0.05,'y_offset',-.05,'font_size',24);
labelAxes(ax.S,'F','x_offset',-0.05,'y_offset',-.05,'font_size',24);

deintersectAxes(ax.AB)
deintersectAxes(ax.LP)
deintersectAxes(ax.PY)
deintersectAxes(ax.S)
