function [Q,S] = loadNeuronData(filename)

  % make a vector of dt to vary
  max_dt = 1e3;
  K = 1:max_dt;
  all_dt = K(rem(max_dt,K) == 0);
  all_dt = all_dt/1e3;

  % simulation time
  t_end = 30000;

  % set up a hash
  % checks the filename and the contents of this function
  h = [filename GetMD5(which(mfilename),'File')];

  % if there is no cached data, perform computation
  if isempty(cache(h))

    % load the NEURON data
    disp('loading NEURON data...')
    all_V = csvread([filename '_raw.csv']); % this is 3.3 GB
    disp('NEURON data loaded...')
    for i = length(all_dt):-1:1
      textbar(length(all_dt)-i, length(all_dt))
      V = nonnans(all_V(:,i));
    	all_f(i) = xolotl.findNSpikes(V,-20);
    	all_f(i) = all_f(i)/(t_end*1e-3);
    end

    % measure the baseline error using the LeMasson matrix
    V0 = nonnans(all_V(:,1));
    [M0, V_lim, dV_lim] = xolotl.V2matrix(V0);

    % compute the matrix error relative to the baseline error
    for i = length(all_dt):-1:2
      V = nonnans(all_V(:,i));
    	M = xolotl.V2matrix(V, V_lim, dV_lim);
    	matrix_error(i) = xolotl.matrixCost(M0,M);
    end

    % store the matrix error
    Q = matrix_error;

    % store the speed
    S = csvread([filename '.csv'])

    % cache the speed and error
  	cache(h, Q, S)

    % if cached data exists, load it
  else
    % retrieve the cached speed and error
  	[Q, S] = cache(h);
  end
