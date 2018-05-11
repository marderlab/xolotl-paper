%% Figure 1: Minimal Code, Maximal Output

% set up xolotl object
% with Hodgkin-Huxley type dynamics
x     = xolotl;
x.add('HH', 'compartment', 'Cm', 10, 'A', 0.01);
x.HH.add('liu/NaV', 'gbar', 1000, 'E', 50);
x.HH.add('liu/Kd', 'gbar', 300, 'E', -80);
x.HH.add('Leak', 'gbar', 1, 'E', -50);
x.show(x.HH.find('conductance'))

% plot voltage
x.t_end = 1e3;
x.plot(0.1)

% make FI curve

all_I_ext = linspace(-1,3,50);
all_f = NaN*all_I_ext;

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
end
