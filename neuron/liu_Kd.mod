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
	(nA)	=	(milliamp)
}

PARAMETER {
	gbar (uS/mm2) < 0, 1e9 >
	Erev = -80 (mV)
}

ASSIGNED {
	i (nA/mm2)
	v (mV)
	g (S/mm2)
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
