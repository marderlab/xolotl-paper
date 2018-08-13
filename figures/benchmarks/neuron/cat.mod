INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	SUFFIX cat
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
:	celsius	= 36	(degC)
:	eca	= 120	(mV)
	gbar (S/cm2) := .00175 (mho/cm2)
:	shift	= 2 	(mV)		: screening charge for Ca_o = 2 mM
	cai  (mM) : = 2.4e-4 (mM)		: adjusted for eca=120 mV
                                        : p.2319 Liu et al. 1998
	cao	= 3	(mM)            : original 2 (mM)
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
	carev = (1e3) * (R*(celsius+273.15))/(2*FARADAY) * log (cao/cai)
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
	m = 0
	h = 1
}

PROCEDURE evaluate_fct(v(mV)) {

	m_inf= 1.0 / (1+exp( -(v+27.1)/7.2 ))
	h_inf= 1.0 / (1+exp( (v+32.1)/5.5 ))

	tau_m =  21.7 - 21.3 / (1+exp( -(v+68.1)/20.5 ))
	tau_h =  105 - 89.8 / (1+exp( -(v+55)/16.9 ))

}
UNITSON
