NEURON {
	SUFFIX hcurrent
	NONSPECIFIC_CURRENT i
	RANGE i, Erev
}

UNITS {
	(S)	=	(siemens)
	(mV)	=	(millivolt)
	(mA)	=	(milliamp)
}

PARAMETER {
	gbar = 0 (S/cm2)
	Erev = -20 (mV)
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
	taum = (272.0 + 1499.0/(1.0+exp((Vm+42.2)/-8.73)))
	UNITSON
}

PROCEDURE rates(Vm(mV)) {
	tau_m = taum(Vm)
	UNITSOFF
	minf = 1.0/(1.0+exp((Vm+70.0)/6.0))
	UNITSON
}
