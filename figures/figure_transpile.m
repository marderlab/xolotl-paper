% test transpile and compile speed in xolotl

nComps      = round(logspace(1, 3, 11));
init_time   = zeros(length(nComps), 1);
trans_time  = zeros(length(nComps), 1);
comp_time   = zeros(length(nComps), 1);
sim_time    = zeros(length(nComps), 1);

fig = figure; hold on;

% perform benchmarking
for ii = 1:length(nComps)
  textbar(ii, length(nComps))

  % set up the xolotl object
  clear x

  % benchmark instantiation
  tic;
  x = xolotl;
  x.cleanup
  x.skip_hash = true;
  for qq = 1:nComps(ii)
    compName = ['HH' mat2str(qq)];
    x.add(compName, 'compartment', 'Cm', 10, 'A', 0.01);
    x.(compName).add('liu/NaV', 'gbar', 1000, 'E', 50);
    x.(compName).add('liu/Kd', 'gbar', 300, 'E', -80);
    x.(compName).add('Leak', 'gbar', 1, 'E', -50);
  end
  x.skip_hash = false;
  x.md5hash
  init_time(ii) = toc;

  % benchmark transpiling
  tic;
  x.transpile;
  trans_time(ii) = toc;

  % benchmark compiling
  tic;
  x.compile;
  comp_time(ii) = toc;

  % benchmark simulation
  x.sim_dt = 0.1;
  x.dt = 0.1;
  x.t_end = 1000;
  Iext = 0.2 * ones(nComps(ii), 1);
  tic;
  x.integrate;
  sim_time(ii) = toc;

  % plot now
  plot(nComps(ii), init_time(ii), 'ko')
  plot(nComps(ii), trans_time(ii), 'ro')
  plot(nComps(ii), comp_time(ii), 'bo')
  plot(nComps(ii), sim_time(ii), 'go')

  drawnow
end
