% make figure of slice time over number of slices
nSlices = [1 linspace(10,100,10)];
time    = zeros(length(nSlices),1);     % s
I_ext   = 0.1 * ones(max(nSlices),1);   % nA

for ii = 1:length(nSlices)
  textbar(ii,length(nSlices))
  % create xolotl object with two conductances
  x = xolotl;
  x.add('HH','compartment','V', -65, 'Ca', 0.02, 'Cm', 10, ...
    'radius', 0.025, 'len', 0.050);
  x.HH.add('liu-approx/NaV', 'gbar', 1000, 'E', 50);
  x.HH.add('liu-approx/Kd', 'gbar', 300, 'E', -80);
  x.HH.add('Leak', 'gbar', 1, 'E', -50);
  if nSlices(ii) ~= 1
    x.slice('HH',nSlices(ii),100);
  end
  x.sha1hash;
  % set up simulation
  x.t_end = 100e3;  % ms
  x.dt = 0.05;      % ms
  V = zeros(x.t_end/x.dt,nSlices(ii));
  % test simulation speed
  tic;
  V = x.integrate(I_ext(1:nSlices(ii)));
  time(ii) = toc;
end

figure;

subplot(1,2,1)
plot(nSlices,time)
xlabel('# of slices')
ylabel('time (s)')
title('run-time vs. slicing')

subplot(1,2,2)
hold on
plot(nSlices,x.t_end/1000/time)
xlabel('# of slices')
ylabel('speed factor')
title('sim-time/run-time vs. slicing')

equalizeAxes(); prettyFig();
