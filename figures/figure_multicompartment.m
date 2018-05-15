%% Figure 3: Creating and Implementing a Network

% set up xolotl object
x = make2C;
x.sha1hash;

%% Make Figure

x.handles.fig = figure('outerposition',[0 0 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax

% cartoon cell
x.handles.ax(1) = subplot(3,3,1);
% xolotl structure
x.handles.ax(2) = subplot(3,3,2);
% xolotl printout
x.handles.ax(3) = subplot(3,3,3);
% voltage trace
x.handles.ax(4) = subplot(3,1,2); hold on;
x.handles.ax(5) = subplot(3,1,3); hold on;
% x.handles.ax(6) = subplot(4,1,4); hold on;

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
  legend(x.(nameComps{ii}).find('conductance'))
end

%% Post-Processing

prettyFig()
labelFigure('capitalise', true) % this doesn't work
