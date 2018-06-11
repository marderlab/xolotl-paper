
x.add('AB','compartment','vol',.0628,'phi',906);
x.add('LP','compartment','vol',.0628,'phi',906);
x.add('PY','compartment','vol',.0628,'phi',906);

% set up conductances...

% set up synapses 
x.connect('AB','LP','Chol','gbar',30);
x.connect('LP','AB','Glut','gbar',30);

[V,~,~,I_syn] = x.integrate;