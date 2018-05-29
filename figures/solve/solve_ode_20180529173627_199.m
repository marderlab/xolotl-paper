function [T,pop1_v,pop1_m,pop1_h,pop1_n]=solve_ode
% ------------------------------------------------------------
% Parameters:
% ------------------------------------------------------------
params = load('params.mat','p');
p = params.p;
downsample_factor=p.downsample_factor;
dt=p.dt;
T=(p.tspan(1):dt:p.tspan(2))';
ntime=length(T);
nsamp=length(1:downsample_factor:ntime);
% ------------------------------------------------------------
% Initial conditions:
% ------------------------------------------------------------
% seed the random number generator
rng_wrapper(p.random_seed);
t=0; k=1;

% STATE_VARIABLES:
pop1_v = zeros(nsamp,p.pop1_Npop);
  pop1_v(1,:) = -65 * ones(1,p.pop1_Npop);
pop1_m = zeros(nsamp,p.pop1_Npop);
  pop1_m(1,:) = 0 * ones(1,p.pop1_Npop);
pop1_h = zeros(nsamp,p.pop1_Npop);
  pop1_h(1,:) = 1 * ones(1,p.pop1_Npop);
pop1_n = zeros(nsamp,p.pop1_Npop);
  pop1_n(1,:) = 0 * ones(1,p.pop1_Npop);
% ###########################################################
% Numerical integration:
% ###########################################################
% seed the random number generator
rng_wrapper(p.random_seed);
n=2;
for k=2:ntime
  t=T(k-1);
  pop1_v_k1=(0.2/0.01-((p.pop1_gNa.*pop1_m(n-1).^3.*pop1_h(n-1).*(pop1_v(n-1)-50)))-((p.pop1_gKd.*pop1_n(n-1).^4.*(pop1_v(n-1)+80)))-((p.pop1_gLeak.*(pop1_v(n-1)+50))))/p.pop1_Cm;
  pop1_m_k1=(((1.0/(1.0+exp((pop1_v(n-1)+25.5)/-5.29))))-pop1_m(n-1))/((1.32-1.26/(1+exp((pop1_v(n-1)+120.0)/-25.0))));
  pop1_h_k1=(((1.0/(1.0+exp((pop1_v(n-1)+48.9)/5.18))))-pop1_h(n-1))/(((0.67/(1.0+exp((pop1_v(n-1)+62.9)/-10.0)))*(1.5+1.0/(1.0+exp((pop1_v(n-1)+34.9)/3.6)))));
  pop1_n_k1=(((1.0/(1.0+exp((pop1_v(n-1)+12.3)/-11.8))))-pop1_n(n-1))/((7.2-6.4/(1.0+exp((pop1_v(n-1)+28.3)/-19.2))));
  t=t+.5*dt;
  pop1_v_k2=(0.2/0.01-((p.pop1_gNa.*((pop1_m(n-1)+.5*dt*pop1_m_k1)).^3.*((pop1_h(n-1)+.5*dt*pop1_h_k1)).*(((pop1_v(n-1)+.5*dt*pop1_v_k1))-50)))-((p.pop1_gKd.*((pop1_n(n-1)+.5*dt*pop1_n_k1)).^4.*(((pop1_v(n-1)+.5*dt*pop1_v_k1))+80)))-((p.pop1_gLeak.*(((pop1_v(n-1)+.5*dt*pop1_v_k1))+50))))/p.pop1_Cm;
  pop1_m_k2=(((1.0/(1.0+exp((((pop1_v(n-1)+.5*dt*pop1_v_k1))+25.5)/-5.29))))-((pop1_m(n-1)+.5*dt*pop1_m_k1)))/((1.32-1.26/(1+exp((((pop1_v(n-1)+.5*dt*pop1_v_k1))+120.0)/-25.0))));
  pop1_h_k2=(((1.0/(1.0+exp((((pop1_v(n-1)+.5*dt*pop1_v_k1))+48.9)/5.18))))-((pop1_h(n-1)+.5*dt*pop1_h_k1)))/(((0.67/(1.0+exp((((pop1_v(n-1)+.5*dt*pop1_v_k1))+62.9)/-10.0)))*(1.5+1.0/(1.0+exp((((pop1_v(n-1)+.5*dt*pop1_v_k1))+34.9)/3.6)))));
  pop1_n_k2=(((1.0/(1.0+exp((((pop1_v(n-1)+.5*dt*pop1_v_k1))+12.3)/-11.8))))-((pop1_n(n-1)+.5*dt*pop1_n_k1)))/((7.2-6.4/(1.0+exp((((pop1_v(n-1)+.5*dt*pop1_v_k1))+28.3)/-19.2))));
  % ------------------------------------------------------------
  % Update state variables:
  % ------------------------------------------------------------
  pop1_v(n)=pop1_v(n-1)+dt*pop1_v_k2;
  pop1_m(n)=pop1_m(n-1)+dt*pop1_m_k2;
  pop1_h(n)=pop1_h(n-1)+dt*pop1_h_k2;
  pop1_n(n)=pop1_n(n-1)+dt*pop1_n_k2;
  n=n+1;
end

T=T(1:downsample_factor:ntime);

end

