TITLE Calcium decay

: change in time constant, and the factor that multiplies ica
: to match Liu et al. 1998 p2319 last eqn. and paragraph. Tom M Morse 20070802
: modified from cadecay.mod file in ModelDB accession number 2733
: as described in Bhalla and Bower, J. Neurophysiol. 69:1948-1983 (1993)
: written by Andrew Davison
: partially based on cadecay.mod by Alain Destexhe, Salk Institute 1995.
: 25-08-98

INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms) }

NEURON{
	SUFFIX cad
	USEION ca READ ica, cai WRITE cai
	RANGE ica
	GLOBAL cai
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(molar) = (1/liter)
	(mM) = (millimolar)
	(um) = (micron)
	(nA) = (nanoamp)
}

CONSTANT {
        FARADAY=96485.309
}

PARAMETER {
	A = 0.000628 (cm2)
	f = 1496 (mM/mA)
	tau_Ca = 200 (ms)
	ca0 = 5e-5 (mM)
	dt (ms)
	ica		(mA/cm2)
}

STATE {
	cai		(mM)
}

INITIAL {
	cai = ca0
}

ASSIGNED {
	Ca_inf (mM)
}

BREAKPOINT {
	SOLVE state METHOD cnexp
}

DERIVATIVE state {
  Ca_inf = ca0 - (f * A * ica)
  cai' = (Ca_inf - cai)/tau_Ca
}
