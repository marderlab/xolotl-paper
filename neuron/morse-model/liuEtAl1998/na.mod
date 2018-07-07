COMMENT
This file, na.mod, implements the INa current from 
Liu et al. 1998 (Activity dependent conductances
Tom M Morse 20070803
ENDCOMMENT

NEURON {
	SUFFIX na
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
	gbar	(S/cm2) < 0, 1e9 >
	Erev = 50 (mV)
}

ASSIGNED {
	i (mA/cm2)
	v (mV)
	g (S/cm2)
	minf
	hinf
	tau_h (ms)
	tau_m (ms)
}

STATE {	m h }

BREAKPOINT {
	SOLVE states METHOD cnexp
	g = gbar * m^3 * h
	i = g * (v - Erev)
}

INITIAL {
	: assume that v has been constant for a long time
	rates(v)
	m = minf
	h = hinf
}
DERIVATIVE states {
	rates(v)
	m' = (minf - m)/tau_m
	h' = (hinf - h)/tau_h
}

FUNCTION taum(Vm (mV)) (ms) {
	UNITSOFF
	taum = 1.32 - 1.26/(1+exp( (Vm+120)/(-25.0) ))
	UNITSON
}

FUNCTION tauh(Vm (mV)) (ms) {
	UNITSOFF
	tauh = (0.67/(1+exp( (Vm+62.9)/(-10.0) )))*(1.5+1/(1+exp( (Vm+34.9)/3.6 )))
	UNITSON
}

PROCEDURE rates(Vm(mV)) {
	UNITSOFF
	minf = 1/(1+exp( (Vm+25.5)/(-5.29) ))
	hinf = 1/(1+exp( (Vm+48.9)/5.18 ))
	UNITSON
	tau_h = tauh(Vm)
	tau_m = taum(Vm)
}
