%% Figure 1: Minimal Code, Maximal Output

% set up xolotl object
% with Hodgkin-Huxley type dynamics
x     = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);


% get voltage trace
x.t_end = 1e3;

x.plot(0.1);
fig = gcf;
yyaxis(fig.Children(2), 'left');
Vlines = fig.Children(2).Children;

% get FI relation
all_I_ext = linspace(-1,1,50);
all_f = NaN*all_I_ext;

for i = 1:length(all_I_ext)
	V = x.integrate(all_I_ext(i));
	all_f(i) = length(computeOnsOffs(V>0))/(x.t_end*1e-3);
end

% get activation, inactivation, and time constant values
x.show(x.HH.find('conductance'))
fig = gcf;

counter = 0;
output = zeros(1000,counter);
for ax = 2:length(fig.Children)
  for ii = 1:length(fig.Children(ax).Children)
    counter = counter + 1;
    output(:,counter) = vectorise(fig.Children(ax).Children(ii).YData);
  end
end

close; clear fig;

%% Make Figure

x.handles.fig = figure('outerposition',[0 0 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax;

% cartoon cell
x.handles.ax(1) = subplot(3,3,1);
% xolotl structure
x.handles.ax(2) = subplot(3,3,2);
% xolotl readout from MATLAB
x.handles.ax(3) = subplot(3,3,3);
% voltage trace
x.handles.ax(4) = subplot(3,2,3);
% x.handles.ax(5)
% x.handles.ax(6)
% FI curve
x.handles.ax(7) = subplot(3,2,4);
for ii = 8:11
  x.handles.ax(ii) = subplot(3,4,ii+1);
end

% add voltage

% add FI curve


figure('outerposition',[100 100 500 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
xh = plot(NaN,NaN,'k-o');
xh_rev = plot(NaN,NaN,'r-o');
xlabel('I_{ext} (nA)')
ylabel('Firing rate (Hz)')
set(gca,'YLim',[-1 150],'XLim',[min(all_I_ext) max(all_I_ext)])

prettyFig();


for i = 1:length(all_I_ext)
	V = x.integrate(all_I_ext(i));
	all_f(i) = length(computeOnsOffs(V>0))/(x.t_end*1e-3);
	xh.XData = all_I_ext;
	xh.YData = all_f;
	drawnow;
end
