% this is an example of a custom plot function
% that can be used by manipulate
% this function generates a f-I curve from a xolotl
% object that is supposedly has one compartment 

function make_fI(x)

S = x.serialize;

n_steps = 30;
all_I_ext = [linspace(-.05,.2,n_steps)];
t_end = 3e3;


if isempty(x.handles) || ~isfield(x.handles,'figfI') || ~isvalid(x.handles.figfI)

	% no base figure, make it
	x.handles.figfI = [];
	x.handles.figfI = figure('outerposition',[100 100 600 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

	x.handles.xh1 = plot(NaN,NaN,'k');
	x.handles.xh2 = plot(NaN,NaN,'r');

	xlabel('I_{ext} (nA)')
	ylabel('Firing rate (Hz)')
	set(gca,'YLim',[-10 100],'XLim',[min(all_I_ext) max(all_I_ext)])


	x.handles.xh1.XData = all_I_ext(1:n_steps);
	x.handles.xh2.XData = all_I_ext(n_steps+1:end);
	x.handles.xh1.YData = NaN*all_I_ext(1:n_steps);
	x.handles.xh2.YData = NaN*all_I_ext(n_steps+1:end);

	x.handles.puppeteer_object.attachFigure(x.handles.figfI);



end


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

x.handles.xh1.YData = all_f(1:n_steps);
x.handles.xh2.YData = all_f(n_steps+1:end);

% restore the xolotl object the its original state
x.deserialize(S);

x.I_ext = .2;

drawnow;