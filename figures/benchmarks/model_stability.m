% show that the integration method is stable over increasing time step
% creates a supplementary figure that shows the stability of
% a model with varied maximal conductances over increasing time-step

% create the xolotl model
x = xolotl;
x.add('compartment','AB','A',0.0628,'phi',90,'vol',.0628);

x.AB.add('liu/NaV','gbar', 0,'E',30);
x.AB.add('liu/CaT','gbar', 0,'E',30);
x.AB.add('liu/CaS','gbar', 0,'E',30);
x.AB.add('liu/ACurrent','gbar', 0,'E',-80);
x.AB.add('liu/KCa','gbar', 0,'E',-80);
x.AB.add('liu/Kd','gbar', 0,'E',-80);
x.AB.add('liu/HCurrent','gbar', 0,'E',-20);
x.AB.add('Leak','gbar', 0,'E',-50);
x.t_end = 1e4;

% test run
x.integrate;

% for each set of conductances, simulate the model
% over a series of time-steps

% make a vector of dt to vary
max_dt = 1e3;
K = 1:max_dt;
all_dt = K(rem(max_dt,K) == 0);
all_dt = all_dt/1e3;

% vector to store the voltage traces
all_V = NaN(ceil(x.t_end/x.dt),length(all_dt));

% matrix of all conductances
% size = nConds x nModels
cond_matrix = [];

h0 = GetMD5(all_dt);
[~, h1] = x.md5hash;
h2 = GetMD5(all_conds);
h = GetMD5([h0,h1,h2]);

if isempty(cache(h))

  for model = 1:size(cond_matrix, 2)
    textbar(model, size(cond_matrix, 2))
    % set up the xolotl object with the new conductances
    x.set('*gbar', cond_matrix(:, model));
    % run through the benchmark test over increasing dt
  	for i = length(all_dt):-1:1
      textbar(length(all_dt) - i, length(all_dt))
      % set up the new time step
  		x.sim_dt = all_dt(i);
  		x.dt = 1;
      % run the simulation
  		all_V(:,i) = x.integrate;
  	end
    % acquire the spike times
    for i = length(all_dt):-1:1
    	all_f(i) = xolotl.findNSpikes(all_V(:,i),-20);
    	all_f(i) = all_f(i)/(x.t_end*1e-3);
    end
    % measure the errors using the LeMasson matrix
    [M0, V_lim, dV_lim] = xolotl.V2matrix(all_V(:,1));
    for i = length(all_dt):-1:2
    	M = xolotl.V2matrix(all_V(:,i),V_lim, dV_lim);
    	matrix_error(i) = xolotl.matrixCost(M0,M);
    end
    Q = matrix_error;
    % cache the results for next time
    cache(h, Q);

else

  Q = cache(h);

end

% generate a figure
figure('outerposition',[100 100 1550 666],'PaperUnits','points','PaperSize',[1000 1000]); hold on
% plot the error over time-step
plot(all_dt, Q)
set('XScale','log','YScale','log')
xlabel('\Deltat (ms)')
ylabel('Simulation error (\epsilon_{HH})')