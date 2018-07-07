COMMENT
This file, h.mod, implements the Ih hyperpolarization activated cation nonspecific
current from Liu et al. 1998 (Activity dependent conductances) table p.2319
Tom M Morse 20070803
ENDCOMMENT

NEURON {
	SUFFIX h
	NONSPECIFIC_CURRENT i
	POINTER gbar
	RANGE i, Erev
}

UNITS {
	(S)	=	(siemens)
	(mV)	=	(millivolt)
	(mA)	=	(milliamp)
}

PARAMETER {
	gbar (S/cm2) : = 2e-6	(S/cm2) < 0, 1e9 > : this value gets overwritten by activity dependent regulation
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
	g = gbar * m
	i = g * (v - Erev)
}

INITIAL {
	: assume that v has been constant for a long time
	rates(v)
	m = minf
}
DERIVATIVE states {
	rates(v)
	m' = (minf - m)/tau_m
}

FUNCTION taum(Vm (mV)) (ms) {
	UNITSOFF
	taum = 272+1499/(1+exp(-(Vm+42.2)/8.73))
	UNITSON
}

PROCEDURE rates(Vm(mV)) {
	tau_m = taum(Vm)
	UNITSOFF
	minf = 1/(1+exp((Vm+70)/6))
	UNITSON
}
