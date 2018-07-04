NEURON {
	SUFFIX kd
	NONSPECIFIC_CURRENT i
	RANGE i, Erev, gbar
}

UNITS {
	(S)	=	(siemens)
	(mV)	=	(millivolt)
	(mA)	=	(milliamp)
}

PARAMETER {
	gbar = 0.3 (S/cm2)
	Erev = -80 (mV)
}

ASSIGNED {
	i (mA/cm2)
	v (mV)
	g (S/cm2)
	minf
	tau_m (ms)
}

STATE {	m }

BREAKPOINT {
	SOLVE states METHOD cnexp
	g = gbar * m^4
	i = g * (v - Erev)
}

INITIAL {
	m = 0
}
DERIVATIVE states {
	rates(v)
	m' = (minf - m)/tau_m
}

FUNCTION taum(Vm (mV)) (ms) {
	UNITSOFF
	taum = 7.2-6.4/(1+exp(-(Vm+28.3)/19.2))
	UNITSON
}

PROCEDURE rates(Vm(mV)) {
	tau_m = taum(Vm)
	UNITSOFF
	minf = 1/(1+exp(-(Vm+12.3)/11.8))
	UNITSON
}
