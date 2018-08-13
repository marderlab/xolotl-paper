

% make the figure


fig = figure('outerposition',[0 0 1300 920],'PaperUnits','points','PaperSize',[1300 920]); hold on
clear ax
ax.Ca(1) = subplot(5,4,2); hold on
ax.V(1) = subplot(5,4,6); hold on


ax.Ca(2) = subplot(5,4,4); hold on
ax.V(2) = subplot(5,4,8); hold on

% time traces
ax.Ca(3) = subplot(5,2,6); hold on
ax.g = subplot(5,2,8); hold on

% voltage traces
ax.V(3) = subplot(5,3,13); hold on
ax.V(4) = subplot(5,3,14); hold on
ax.V(5) = subplot(5,3,15); hold on

x = xolotl;
x.add('compartment','AB','A',.0628,'Ca_target',7);

g0 = 1e-1+1e-1*rand(7,1);

x.AB.add('liu/NaV','gbar',3396,'E',30);
x.AB.add('liu/CaT','gbar',42);
x.AB.add('liu/CaS','gbar',51);
x.AB.add('liu/ACurrent','gbar',228);
x.AB.add('liu/KCa','gbar',1812);
x.AB.add('liu/Kd','gbar',1133);
x.AB.add('liu/HCurrent','gbar',20);
x.AB.add('Leak','gbar',.0989,'E',-55);

x.dt = .1;
x.sim_dt = .1;
x.t_end = 5e3;
x.integrate;
[V,Ca] = x.integrate; Ca = Ca(:,1);

time = (1:length(V))*x.dt;
plot(ax.Ca(1),time,Ca,'k')

plot(ax.V(1),time,V,'k')
set(ax.Ca(1),'XLim',[0 202],'XTick',[0 100 200],'YLim',[-2 15],'YScale','linear')
set(ax.V(1),'XLim',[0 202],'XTick',[0 100 200],'YLim',[-80 40],'YTick',-80:40:40)


% now add the calcium mech

x.AB.add('CalciumMech1','f',1.496);

x.integrate; x.integrate;
[V,Ca] = x.integrate; Ca = Ca(:,1);

time = (1:length(V))*x.dt;
plot(ax.Ca(2),time,Ca,'k')

plot(ax.V(2),time,V,'k')

set(ax.Ca(2),'XLim',[0 503],'XTick',[0 250 500],'YLim',[-2 15],'YScale','linear')
set(ax.V(2),'XLim',[0 503],'XTick',[0 250 500],'YLim',[-80 40],'YTick',-80:40:40)



x.AB.NaV.add('IntegralController');
x.AB.CaT.add('IntegralController');
x.AB.CaS.add('IntegralController');
x.AB.ACurrent.add('IntegralController');
x.AB.KCa.add('IntegralController');
x.AB.Kd.add('IntegralController');
x.AB.HCurrent.add('IntegralController');

% add a calium sensor
x.AB.add('CalciumSensor');

% configure controller parameters
x.set('*tau_m',1e4./[1 .22 .18 .08 8 5 15])
x.set('*Controller.m',1e-1+1e-2*rand(7,1))
x.set('*gbar',rand(8,1)*1e-1+1e-1)
x.AB.Ca = x.AB.CalciumMech1.Ca_in;

x.sim_dt = .1;
x.dt = 100;

x.t_end = .5e3;
[~,~,C0] = x.integrate;
x.snapshot('before');

x.t_end = 9.5e3;
[~,~,C1] = x.integrate;
x.snapshot('during');

x.t_end = 990e3;
[~,~,C2] = x.integrate;
x.snapshot('after');

C = [C0; C1; C2];


Ca = C(:,7);
C(:,7) = [];

g = C(:,2:2:end);


time = (1:length(Ca))*100*1e-3;
colours = brighten(othercolor('Mrainbow',8),.1);



% plot Ca
plot(ax.Ca(3),time,x.AB.Ca_target + 0*Ca(:,1),'r--')
plot(ax.Ca(3),time,Ca,'k')
set(ax.Ca(3),'XScale','log','YScale','log')
ylabel(ax.Ca(3),'<[Ca^2^+]> (\muM)')


% plot g
for i = 1:size(g,2)
	plot(ax.g,time,g(:,i),'Color',colours(i,:))
end
set(ax.g,'XScale','log','YScale','log','YLim',[1e-2 1e4])
ylabel(ax.g,'g (\muS/mm^2)')
xlabel(ax.g,'Time (s)')

% show the voltage plots
x.reset('before')
x.t_end = 5e2; x.dt = .1; V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(ax.V(3),time,V,'k')
set(ax.V(3),'YLim',[-80 40])


x.reset('during')
x.t_end = 5e2; x.dt = .1; V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(ax.V(4),time,V,'k')
set(ax.V(4),'YLim',[-80 40])

x.reset('after')
x.t_end = 5e2; x.dt = .1; V = x.integrate;
time = (1:length(V))*x.dt*1e-3;
plot(ax.V(5),time,V,'k')
set(ax.V(5),'YLim',[-80 40])


axis(ax.V(4:5),'off')
ax.Ca(3).XTickLabel = '';
prettyFig('plw',1.5,'lw',1.5,'fs',17);

ylabel(ax.Ca(1),'[Ca^2^+] (\muM)')
ylabel(ax.Ca(2),'[Ca^2^+] (\muM)')
xlabel(ax.V(1),'Time (ms)')
xlabel(ax.V(2),'Time (ms)')
ylabel(ax.V(1),'V_m (mV)')
ylabel(ax.V(2),'V_m (mV)')

% make top four plots shorter
for i = 1:2
	ax.Ca(i).Position(4) = .1;
	ax.V(i).Position(4) = .1;

end

movePlot(ax.Ca(1:2),'left',.007)
movePlot(ax.Ca(1:2),'up',.04)
movePlot(ax.V(1:2),'up',.06)


for i = 3:5
	ax.V(i).Position(3) = .1;
	ax.V(i).Position(4) = .08;
	ax.V(i).Position(2) = .08;
end
ax.V(3).XTick = [0 .4];
ax.V(3).XLim = [0 .4];
ax.V(3).YTick = [-80 0 40];
ax.V(5).Position(1) = .8;
ax.V(4).Position(1) = .65;
ax.V(3).Position(1) = .5;
ylabel(ax.V(3),'V_m (mV)')

% align other plots 
ax.Ca(3).Position(1) = .45;
ax.Ca(3).Position(3) = .45;

ax.g.Position(1) = .45;
ax.g.Position(3) = .45;

% move all integral control plots down

movePlot(ax.Ca(3),'down',.05)
movePlot(ax.g,'down',.05)

% draw rectangles to group figures

ax.base = axes(fig); hold on
ax.base.Position = [0 0 1 1];
ax.base.XLim = [0 1];
ax.base.YLim = [0 1];
uistack(ax.base,'bottom');
axis(ax.base,'off')

for i = 3:-1:1
	rect(i) = rectangle(ax.base,'Curvature',.1,'LineWidth',2,'EdgeColor',[.5 .5 .5]);
end

rect(1).Position = [.03 .61 .48 .35];
rect(2).Position = [.53 .61 .4 .35];
rect(3).Position = [.03 .03 .9 .55];


ax.Ca(1).XColor = 'w';
ax.Ca(2).XColor = 'w';

% deintersct axes
for i = 1:2
	deintersectAxes(ax.V(i))
end
deintersectAxes(ax.Ca(3))
deintersectAxes(ax.g)

% % make labels
% L = {'A','B','C'};
% for i = 3:-1:1
% 	t(i) = text(ax.base,.4,.4,L{i},'FontSize',24,'FontWeight','bold');
% end

% t(1).Position = [.02 .97];
% t(2).Position = [.52 .97];
% t(3).Position = [.02 .58];