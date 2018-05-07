% make figure of slice time over number of slices
nSlices = 2:100;
time    = zeros(length(nSlices),1);

for ii = nSlices
  textbar(ii,length(nSlices))
  x = make_neuron();
  x.AB.radius = 25;
  x.AB.len = 400;
  x.sha1hash;
  tic;
  x.slice('AB',nSlices(ii),100);
  time(ii) = toc;
end

figure;
plot(nSlices,time)
xlabel('# of slices')
ylabel('time (s)')
title('runtime vs. slicing')
prettyFig();
