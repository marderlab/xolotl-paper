function [xprime]=  neuron_standalone(t, x, g)
% Neuron_standalone.m
% you need to call it using an ode solver, e.g.:
%[t n] = ode23t(@neuron_standalone, [0, tend], n0);
% last edit @ 19:00 on Saturday the 27th
% this is supposed to be called by STGnetwork.m
% this function works for any neuron : g specifies which one it is
% 06.10.2009
% 07.10.2009
% Dimensional Analysis and Unit checking
% making sense of this:
% x(1)...x(7) : m(1)...m(7)
% x(7)...x(11): h(1)...h(4)
% I(i)s are not treated as a variable
% x(12) : The Voltage V
% x(13) : The intracellular Calcium concentration [Ca]_i
% future changes :
% - fast switching of parameters, neuron-type by function calls.
%%  begin parameters

% g = [100 2.5 6 50 5  100 0.01 0.00]; % ABPD#2
% %g = [100 0 4  20 0 25  0.05 0.03]; % LP#4


C = 0.628*10^(-9); % in Farads
A = 0.628*10^(-7); % in sq. m. (area of cell)
f = 14.96*10^(6); % in milliMol/Ampere;
p = [3 3 3 3 4 4 1]; % dimensionless
extCa = 3; % in milliMol
Cazero = 0.05*10^(-3); %milliMol
tauCa = 0.200; % in seconds.
% now the reversal potential for Ca
ECa = 12.9*(log((extCa)/(x(13)))); % in milliVolts, corrected for divalent Calcium

E = [50 ECa ECa -80 -80 -80 -20 -50]; % in milliVolts. ECa needs to be computed from the Nernst Equation

%% correct units..
g = g*10; % now all in Siemens/sq.m.
%% begin voltage dependency...
%minf
minf = zeros(7,1);
hinf = zeros(4,1);
taum = zeros(7,1);
tauh = zeros(4,1);

minf(1) = 1/(1+exp((x(12) + 25.5)/(-5.29)));
minf(2) = 1/(1+exp((x(12) + 27.1)/(-7.20)));
minf(3) = 1/(1+exp((x(12) + 33.0)/(-8.10)));
minf(4) = 1/(1+exp((x(12) + 27.2)/(-8.70)));
minf(5) = (x(13)/(x(13) + 0.003))*(1/(1 + exp((x(12) + 28.3)/(-12.6)))); % I, calcium dependant, special
minf(6) = 1/(1+exp((x(12) + 12.3)/(-11.80)));
minf(7) = 1/(1+exp((x(12) + 75.0)/(5.5)));
% hinf
hinf(1) = 1/(1+exp((x(12) + 48.9)/5.18));
hinf(2) = 1/(1+exp((x(12) + 32.1)/5.5));
hinf(3) = 1/(1+exp((x(12) + 60)/6.2));
hinf(4) = 1/(1+exp((x(12) + 56.9)/4.9));
% taum..all taus are being computed in ms (maybe)
taum(1) = 2.640 - (2.52/(1 + exp((x(12) + 120)/(-25))));
taum(2) = 43.40 - (42.6/(1 + exp((x(12) + 68.1)/(-20.5))));
taum(3) = 2.800 + (14/(exp((x(12) + 27)/(10)) + exp((x(12) + 70)/(-13))));
taum(4) = 23.20 - (20.8/(1 + exp((x(12) + 32.9)/(-15.2))));
taum(5) = 180.6 - (150.2/(1 + exp((x(12) + 46)/(-22.7))));
taum(6) = 14.40 - (12.8/(1 + exp((x(12) + 28.3)/(-19.2))));
taum(7) = 0.000 + (2/(exp((x(12) + 169.7)/(-11.6)) + exp((x(12) - 26.7)/(14.3))));

% tauh
tauh(1) = (1.34/(1+exp((x(12) + 62.9)/(-10))))*((1.5)+(1/(1+(exp((x(12)+34.9)/(3.6)))))); % hopefully, this is correct
tauh(2) = 210 - (179.6/(1 + exp((x(12) + 55)/(-16.9))));
tauh(3) = 120 + (300/(exp((x(12) + 55)/(9)) + exp((x(12) + 65)/(-16))));
tauh(4) = 77.2 - (58.4/(1 + exp((x(12) + 38.9)/(-26.5))));

taum = taum/1000; % all taums now in seconds
tauh = tauh/1000; % all tauhs now in seconds


xprime(1:7) = (minf - x(1:7))./taum;

xprime(8:11) = (hinf - x(8:11))./tauh;


current = zeros(8,1);

current(1) = g(1)*(x(1)^(p(1)))*x(8) *(x(12) - E(1))*A;
current(2) = g(2)*(x(2)^(p(2)))*x(9) *(x(12) - E(2))*A;
current(3) = g(3)*(x(3)^(p(3)))*x(10)*(x(12) - E(3))*A;
current(4) = g(4)*(x(4)^(p(4)))*x(11)*(x(12) - E(4))*A;
current(5) = g(5)*(x(5)^(p(5)))*      (x(12) - E(5))*A; % this equation looks fishy. check.
current(6) = g(6)*(x(6)^(p(6)))*      (x(12) - E(6))*A; % this equation looks fishy. check.
current(7) = g(7)*(x(7)^(p(7)))*      (x(12) - E(7))*A; % this equation looks fishy. check.
% now the leak current : current(8)
current(8) = g(8)*(x(12)-E(8))*A; % made-up equation, assuming rev. pot.=-50.



% now the equation for Vprime == xprime(12)
xprime(12) = (-sum(current))/C;
% now the calcium equation [Ca] == x(13)
calcium_current = (current(2) + current(3))/1000; %in Amperes, because of f units
xprime(13) = (-f*calcium_current - x(13) + Cazero)/tauCa;
% end system of ODEs


xprime = xprime'; 
