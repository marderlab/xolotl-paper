%% Figure 4: Multicompartment Models

% set up xolotl object
x = make2C;
x.sha1hash;

%% Make Figure

fig = figure('outerposition',[0 0 1200 1200],'PaperUnits','points','PaperSize',[1200 1200]); hold on;
comp_names = x.find('compartment');
N = length(comp_names);
c = lines(100);

clear ax

% cartoon cell
ax(1) = subplot(3,3,1);
% xolotl structure
ax(2) = subplot(3,3,2);
% xolotl printout
ax(3) = subplot(3,3,3);
% voltage trace
ax(4) = subplot(3,1,2); hold on;
ax(5) = subplot(3,1,3); hold on;
% ax(6) = subplot(4,1,4); hold on;

%% Make Cartoon Cell

image(ax(1), imread('figure_network_Prinz_2004.png'))
axis(ax(1), 'off');
ax(1).Tag = 'cartoon';

%% Make Xolotl Structure

image(ax(2), imread('figure_network_diagram.png'))
axis(ax(2), 'off')
ax(1).Tag = 'code_snippet';

%% Make Xolotl Readout from MATLAB

image(ax(3), imread('figure_HH_xolotl_printout.png'))
axis(ax(3), 'off')
ax(1).Tag = 'xolotl_printout';

%% Make Voltage Trace

c           = lines(100);
nameComps   = x.find('compartment');
nComps      = length(nameComps);

% integrate and obtain the current traces
[V, Ca, ~, currents, synaptic_currents]  = x.integrate;
time        = 1e-3 * x.dt * (1:length(V));

% plot the voltage
for ii = 1:nComps
  plot(ax(ii+3), time, V(:,ii), 'k', 'LineWidth', 1)
end

%% Post-Processing

labelFigure('capitalise', true) % this doesn't work
prettyFig()

% remove boxes
for ii = 1:length(ax)
  box(ax(ii), 'off')
end
