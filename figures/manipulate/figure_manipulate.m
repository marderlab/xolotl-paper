%% Figure 1: Minimal Code, Maximal Output

% set up xolotl object
% with Hodgkin-Huxley type dynamics
x = xolotl;


x.add('compartment', 'HH', 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);

x.manipulate_plot_func{2} = @make_fI;

figure('outerposition',[300 300 1800 500],'PaperUnits','points','PaperSize',[1800 500]); hold on
clear ax

ax.V = subplot(1,4,2:3);hold on
ax.fI = subplot(1,4,4);hold on

x.t_end = 200;
x.dt = .1;
V = x.integrate;

x.closed_loop = false;
x.I_ext = .2;
[V, ~, ~, I]  = x.integrate;
time = x.dt * (1:length(V));

curr_index  = x.contributingCurrents(V, I);

c = lines;

% plot the voltage
for i = 1:size(I, 2)
	Vplot = V;
	Vplot(curr_index ~= i) = NaN;
	plot(ax.V, time, Vplot, 'Color', c(i,:),'LineWidth',2.5);
	l(i) = plot(ax.V,NaN,NaN,'o','MarkerFaceColor',c(i,:),'MarkerEdgeColor',c(i,:));
end
legend(l, x.HH.find('conductance'),'Location','northwest')

ylabel(ax.V, ['V_m (mV)'])
set(ax.V, 'XLim', [0 201], 'YLim', [-90 70])
xlabel(ax.V,'Time (ms)')

% plot the fi curve for two parmaeters

n_steps = 30;
all_I_ext = [linspace(-.05,.2,n_steps)];
t_end = 3e3;

x.sim_dt = .1;
x.dt = .1;
I_ext = vectorise(repmat(all_I_ext,t_end/x.sim_dt,1));
x.t_end = t_end*length(all_I_ext);

x.I_ext = I_ext;

V = x.integrate;
V = (reshape(V,length(V)/(n_steps),n_steps));
all_f = NaN*all_I_ext;


for i = 1:length(all_I_ext)
	all_f(i) = length(computeOnsOffs(V(:,i)>0))/(t_end*1e-3);
	
end

plot(ax.fI,all_I_ext,all_f,'k')


x.HH.NaV.gbar = 3000;

V = x.integrate;
V = (reshape(V,length(V)/(n_steps),n_steps));
all_f = NaN*all_I_ext;


for i = 1:length(all_I_ext)
	all_f(i) = length(computeOnsOffs(V(:,i)>0))/(t_end*1e-3);
	
end

ax.fI.YLim = [-5 50];
ax.fI.YTick = [0:10:50];

plot(ax.fI,all_I_ext,all_f,'r')
xlabel(ax.fI,'I_{ext} (nA)')
ylabel(ax.fI,'Firing rate (Hz)')

ax.V.Position = [.4 .2 .34 .75];
ax.fI.Position = [.8 .2 .16 .75];


prettyFig('fs',19);



labelFigure('x_offset',-.03,'y_offset',-.05,'capitalise',true,'font_size',30)

deintersectAxes(ax.V)
deintersectAxes(ax.fI)


