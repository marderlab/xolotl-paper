function [Q,S, dt] = loadNeuronData(filename)

S = csvread([filename '.csv'])


% make a vector of dt to vary
max_dt = 1e3;
K = 1:max_dt;
all_dt = K(rem(max_dt,K) == 0);
all_dt = all_dt/1e3;

% simulation time
t_end = 30000;


% load the NEURON data
disp('loading NEURON data...')


allfiles = dir([pwd '/neuron/neuron_HH_raw*.npy']);
all_V = {};
all_t = {};
for i = 1:length(allfiles)
	a = strfind(allfiles(i).name,'raw')+3;
	z = strfind(allfiles(i).name,'.npy')-1;

	if any(strfind(allfiles(i).name,'time'))
		continue
	end

	put_here = str2double(allfiles(i).name(a:z));




	all_V{put_here} = (readNPY([allfiles(i).folder filesep allfiles(i).name]));
	all_t{put_here} = (readNPY([allfiles(i).folder filesep allfiles(i).name(1:a-1) '_time' mat2str(put_here) '.npy' ]));
end

% compute dt, because NEURON can't be trusted to 
% do what you tell it to 
dt = 30e3./(cellfun(@length,all_V)-1);

V = NaN(30e3,length(dt));

for i = 1:length(dt)
	V(:,i) = interp1(all_t{i},all_V{i},1:30e3);
end


% measure the baseline error using the LeMasson matrix
V0 = (V(:,1));
[M0, V_lim, dV_lim] = xolotl.V2matrix(V0);

% compute the matrix error relative to the baseline error
for i = length(dt):-1:2
	this_V = nonnans(V(:,i));
	M = xolotl.V2matrix(this_V, V_lim, dV_lim);
	matrix_error(i) = xolotl.matrixCost(M0,M);
end


Q = matrix_error;


