%% Increasing Number of Compartments


dt          = 0.1;  % ms
t_end       = 30e3; % ms
nComps      = unique(round(logspace(0,3,21)));
all_sim_time = NaN*nComps;

h = ['DS_STG' GetMD5(which(mfilename),'File') GetMD5(nComps)];

if isempty(cache(h))

	disp('Increasing number of compartments for dynasim')

	for ii = 1:length(nComps)
		disp(ii)

    % set up dynasim structure
    clear ds
    ds = []; % holds the DynaSim population information
    ds.populations.size       = nComps(ii);
    ds.populations.equations  = equations;

    % give dynasim a trial run
    pleaseDoNotSave = dsSimulate(ds, 'solver', 'rk2', 'tspan', [dt t_end], 'dt', dt, 'compile_flag', 1);

    % time dynasim
		tic
		data = dsSimulate(ds, 'solver', 'rk2', 'tspan', [dt t_end], 'dt', dt, 'compile_flag', 1);
		all_sim_time(ii) = toc;
	end

	S  = all_t_end ./ all_sim_time;
	S  = S * 1e-3;
	cache(h,S)

else
	S = cache(h);
end

plot(ax(5+5),nComps,S,'r-o')
