% make figure of slice time over number of slices
nSlices = 2:10:100;
time    = zeros(length(nSlices),2);
I_ext   = 100 * ones(max(nSlices),1);

for ii = 1:length(nSlices)
  textbar(ii,length(nSlices))
  % create xolotl object with two conductances
  x = xolotl;
  x.add('HH','compartment','V', -65, 'Ca', 0.02, 'Cm', 10, 'A', 0.0628, ...
    'radius', 25, 'len', 400);
  x.HH.add('liu-approx/NaV', 'gbar', 1000, 'E', 50);
  x.HH.add('liu-approx/Kd', 'gbar', 300, 'E', -80);
  x.HH.add('Leak', 'gbar', 1, 'E', -50);
  % test slicing speed
  tic;
  x.slice('HH',nSlices(ii),100);
  time(ii,1) = toc;
  % test simulation speed
  tic;
  x.integrate(I_ext(1:nSlices(ii)));
  time(ii,2) = toc;
end

figure;

subplot(1,2,1)
plot(nSlices,time(:,1))
xlabel('# of slices')
ylabel('time (s)')
title('compile-time vs. slicing')

subplot(1,2,2)
hold on
plot(nSlices,time(:,2))
xlabel('# of slices')
ylabel('time (s)')
title('run-time vs. slicing')

equalizeAxes(); prettyFig();
