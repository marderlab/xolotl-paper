TITLE Calcium decay

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

PARAMETER {
	f = 1496 (mM/mA)
	tau_Ca = 200 (ms)
	ca0 = 0.00005 (mM)
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
  cai' = (-f * ica - cai + ca0)/tau_Ca
}
