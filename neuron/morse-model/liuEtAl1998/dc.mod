COMMENT
This file, dc.mod, implements the Direct current [Ca2+] sensor (D) from
Liu et al. 1998 (Activity dependent conductances)
Tom M Morse 20070807

Note that the transition rates depend on the Ca current, ica,
rather than on the membrane voltage.
ENDCOMMENT

NEURON {
	SUFFIX D
	USEION ca READ ica
	RANGE D
}

UNITS {
	(mA) = (milliamp)
}

PARAMETER {
	G = 1            : p. 2312 after eqn 4
	tau_M = 500 (ms) : p. 2313, table 2
	Z_M = 3          : table 2 also
}

ASSIGNED {
	Mbar (1)  : Mbar and Hbar play the roles of m_inf, h_inf in
	ica (mA/cm2)
	D (1)
}

STATE {	M (1)}

BREAKPOINT {
	SOLVE states METHOD cnexp
	D = G * M * M    : note there is no driving force
}

INITIAL {
	: assume that ica has been constant for a long time at startup
	rates(ica)
	M = Mbar
}
DERIVATIVE states {
	rates(ica)
	M' = (Mbar - M)/tau_M
}

PROCEDURE rates(ica (mA/cm2)) {
	UNITSOFF
	Mbar = 1/(1+exp( Z_M + 1e3*ica )) : units mA/cm2 is 1e-3*nA/nF when
	                              : specific capacitance= 1 uF/cm2
	UNITSON
}
