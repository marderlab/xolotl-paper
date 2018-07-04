NEURON {
	SUFFIX kca
	NONSPECIFIC_CURRENT i
	USEION ca READ cai
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
	cai = 0.05 (mM)
}

ASSIGNED {
	i (mA/cm2)
	v (mV)
	g (S/cm2)
	m_inf
	tau_m (ms)
}

STATE {	m }

BREAKPOINT {
	SOLVE states METHOD cnexp
	g = gbar * m * m * m * m
	i = g * (v - Erev)
}

INITIAL {
	m = 0
}
DERIVATIVE states {
	rates(v, cai)
	m' = (m_inf - m)/tau_m
}

FUNCTION minf(Vm (mV), cai (mM)) {
	UNITSOFF
	minf = (cai/(cai+3.0))/(1.0+exp((Vm+28.3)/-12.6))
	UNITSON
}

FUNCTION taum(Vm (mV)) (ms) {
	UNITSOFF
	taum = 90.3 - 75.1/(1.0+exp((Vm+46.0)/-22.7))
	UNITSON
}

PROCEDURE rates(Vm(mV), cai (mM)) {
	m_inf = minf(Vm, cai)
	tau_m = taum(Vm)
}
