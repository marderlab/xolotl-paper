% tests a neuron that reproduces Fig 3 in Tim's paper



A = 0.0628; % mm^2
Ca_target = 7; % used only when we add in homeostatic control 

x = xolotl;
x.add('compartment','AB','A',A,'Ca_target',Ca_target);
x.AB.add('CalciumMech1','f',1.496);

g0 = 1e-1+1e-1*rand(7,1);

x.AB.add('liu/NaV','gbar',g0(1),'E',30);
x.AB.add('liu/CaT','gbar',g0(2),'E',30);
x.AB.add('liu/CaS','gbar',g0(3),'E',30);
x.AB.add('liu/ACurrent','gbar',g0(4),'E',-80);
x.AB.add('liu/KCa','gbar',g0(5),'E',-80);
x.AB.add('liu/Kd','gbar',g0(6),'E',-80);
x.AB.add('liu/HCurrent','gbar',g0(7),'E',-20);
x.AB.add('Leak','gbar',.099,'E',-50);


x.AB.NaV.add('IntegralController','tau_m',666);
x.AB.CaT.add('IntegralController','tau_m',55555);
x.AB.CaS.add('IntegralController','tau_m',45454);
x.AB.ACurrent.add('IntegralController','tau_m',5000);
x.AB.KCa.add('IntegralController','tau_m',1250);
x.AB.Kd.add('IntegralController','tau_m',2000);
x.AB.HCurrent.add('IntegralController','tau_m',125000);


x.t_end = 5e5;
x.sim_dt = .1;
x.dt = .1;
x.integrate;
x.snapshot('initial')

% delete a channel 
x.set('AB.Ca*.gbar',0)
x.snapshot('noCa')


% re-integrate
x.integrate;
x.snapshot('after-deletion')


% new Ca_target
x.reset('initial');
x.AB.Ca_target = 2;
x.set('*gbar',0)
x.integrate;
x.snapshot('newTarget')


channel_names = x.AB.find('conductance');

for i = 1:length(channel_names)
	channel_names{i} = strrep(channel_names{i},'Current','');
end


c = othercolor('Mrainbow',4);
c = lines;
c([1 3],:) = [];

figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on
ax.cartoon = subplot(2,1,1); hold on
for i = 1:4
	ax.g(i) = subplot(4,4,8+i); hold on
	set(ax.g(i),'XLim',[.5 8.5],'YScale','log','YLim',[1e-2 1e4])
	ax.V(i) = subplot(4,4,12+i); hold on
	set(ax.V(i),'YLim',[-80 40],'XLim',[0 503],'YTick',[-80:40:40],'XTick',[0 250 500])
end


image(ax.cartoon, imread('figure_snapshot.png'))
axis(ax.cartoon, 'off')
axis(ax.cartoon,'ij')


states = {'initial','noCa','after-deletion','newTarget'};

for i = 1:length(states)

	x.reset(states{i})
	g = x.get('*gbar');

	stem(ax.g(i),1:8,g,'filled','Color',c(i,:))
	set(ax.g(i),'XTick',1:8,'XTickLabel',channel_names,'XTickLabelRotation',45);
	x.t_end = 1e3;
	V = x.integrate;
	time = (1:length(V))*x.dt;
	plot(ax.V(i),time,V,'Color',c(i,:))

end

ylabel(ax.g(1),'g (\muS/mm^2)','interpreter','tex')
ylabel(ax.V(1),'V_m (mV)','interpreter','tex')
xlabel(ax.V(1),'Time (ms)','interpreter','tex')

prettyFig('fs',12,'plw',1.5,'lw',1.5);


ax.cartoon.Units = 'pixels';
ax.cartoon.Position = [73         401        1320         260];


% make all gbar plots smaller
for i = 1:length(ax.g)
	ax.g(i).Position(4) = .14;
	ax.g(i).Position(2) = ax.g(i).Position(2) + .02;
end

for i = 1:length(ax.g)
	deintersectAxes(ax.V(i));
end