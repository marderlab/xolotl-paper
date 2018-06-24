NEURON {
	SUFFIX acurrent
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
	Erev = -80 (mV)
}

ASSIGNED {
	i (mA/cm2)
	v (mV)
	g (S/cm2)
	m_inf
	tau_m (ms)
	h_inf
	tau_h (ms)
}

STATE {	m h }

BREAKPOINT {
	SOLVE states METHOD cnexp
	g = gbar * m * m * m * h
	i = g * (v - Erev)
}

INITIAL {
	m = 0
	h = 1
}
DERIVATIVE states {
	rates(v)
	m' = (m_inf - m)/tau_m
	h' = (h_inf - h)/tau_h
}

FUNCTION minf(Vm (mV)) {
	UNITSOFF
	minf = 1.0/(1.0+exp((Vm+27.2)/-8.7))
	UNITSON
}

FUNCTION hinf(Vm (mV)) {
	UNITSOFF
	hinf = 1.0/(1.0+exp((Vm+56.9)/4.9))
	UNITSON
}

FUNCTION taum(Vm (mV)) (ms) {
	UNITSOFF
	taum = 11.6 - 10.4/(1.0+exp((Vm+32.9)/-15.2))
	UNITSON
}

FUNCTION tauh(Vm (mV)) (ms) {
	UNITSOFF
	tauh = 38.6 - 29.2/(1.0+exp((Vm+38.9)/-26.5))
	UNITSON
}

PROCEDURE rates(Vm(mV)) {
	m_inf = minf(Vm)
	tau_m = taum(Vm)
	h_inf = hinf(Vm)
	tau_h = tauh(Vm)
}
