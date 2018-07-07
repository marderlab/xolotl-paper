COMMENT
This file, kd.mod, implements the IKd potassium current from 
Liu et al. 1998 (Activity dependent conductances) table p.2319
Tom M Morse 20070803
ENDCOMMENT

NEURON {
	SUFFIX kd
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
	taum = 7.2-6.4/(1+exp(-(Vm+28.3)/19.2))
	UNITSON
}

PROCEDURE rates(Vm(mV)) {
	tau_m = taum(Vm)
	UNITSOFF
	minf = 1/(1+exp(-(Vm+12.3)/11.8))
	UNITSON
}
