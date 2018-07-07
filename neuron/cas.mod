INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	SUFFIX cas
	USEION ca READ cai WRITE ica
	RANGE m_inf, tau_m, h_inf, tau_h, shift, i, carev, gbar
}

UNITS {
	(molar) = (1/liter)
	(mV) =	(millivolt)
	(mA) =	(milliamp)
	(mM) =	(millimolar)
        (S) = (siemens)
	FARADAY = (faraday) (coulomb)
	R = (k-mole) (joule/degC)
}

PARAMETER {
	v		(mV)
	gbar (S/cm2)
	cai (mM)
	cao	= 3	(mM)
}

STATE {
	m h
}

ASSIGNED {
	ica	(mA/cm2)
	i	(mA/cm2)
	carev	(mV)
	m_inf
	tau_m	(ms)
	h_inf
	tau_h	(ms)
  celsius (degC)
}

BREAKPOINT {
	SOLVE castate METHOD cnexp
	UNITSOFF
	carev = (1e3) * (R*(celsius+273.15))/(2*FARADAY) * log (cao/cai)
	UNITSON
	ica = gbar * m*m*m*h * (v-carev)
	i = ica
}

DERIVATIVE castate {
	evaluate_fct(v)

	m' = (m_inf - m) / tau_m
	h' = (h_inf - h) / tau_h
}

UNITSOFF
INITIAL {
	evaluate_fct(v)
	m = m_inf
	h = h_inf
}

PROCEDURE evaluate_fct(v(mV)) {
	m_inf= 1.0 / (1+exp( -(v+33)/8.1 ))
	h_inf= 1.0 / (1+exp( (v+60)/6.2 ))

	tau_m =  1.4 + 7 / ( exp( (v+27)/10 ) +exp( -(v+70)/13 ) )
	tau_h =  60 + 150 / ( exp( (v+55)/9 ) + exp( -(v+65)/16 ) )
}
UNITSON
