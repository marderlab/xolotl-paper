NEURON {
	SUFFIX cas
	USEION ca READ cai WRITE ica
	RANGE i, Erev
}

UNITS {
	(S)	=	(siemens)
	(mV)	=	(millivolt)
	(mA)	=	(milliamp)
}

PARAMETER {
	gbar = 0 (S/cm2)
	v (mV)
	cai
	cao	= 3	(mM)
}
}

ASSIGNED {
	ica (mA/cm^2)
	i (mA/cm^2)
	carev (mV)
	g (S/cm2)
	m_inf
	tau_m (ms)
	h_inf
	tau_h (ms)
}

STATE {	m h }

BREAKPOINT {
	SOLVE castate METHOD cnexp
	g = gbar * m * m * m * h
	carev = (1e3) * (R*(11+273.15))/(2*FARADAY) * log (cao/cai)
	ica = g * (v-carev)
	i = ica
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
	minf = 1.0/(1.0+exp((Vm+33.0)/-8.1))
	UNITSON
}

FUNCTION hinf(Vm (mV)) {
	UNITSOFF
	hinf = 1.0/(1.0+exp((Vm+60.0)/6.2))
	UNITSON
}

FUNCTION taum(Vm (mV)) (ms) {
	UNITSOFF
	taum = 1.4 + 7.0/(exp((Vm+27.0)/10.0) + exp((Vm+70.0)/-13.0))
	UNITSON
}

FUNCTION tauh(Vm (mV)) (ms) {
	UNITSOFF
	tauh = 60.0 + 150.0/(exp((Vm+55.0)/9.0) + exp((Vm+65.0)/-16.0))
	UNITSON
}

PROCEDURE rates(Vm(mV)) {
	m_inf = minf(Vm)
	h_inf = hinf(Vm)
	tau_m = taum(Vm)
	tau_h = tauh(Vm)
}
