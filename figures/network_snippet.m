

x.add('compartment','AB');
x.add('compartment','LP');
x.add('compartment','PY');

% set up conductances 
% and calcium mechanisms (not shown)

% set up synapses 
x.connect('AB','LP','Chol','gbar',30);
x.connect('LP','AB','Glut','gbar',30);
% and so on...

[V,Ca,~,~,S] = x.integrate;