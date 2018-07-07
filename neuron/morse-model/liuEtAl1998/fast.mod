COMMENT
This file, fast.mod, implements the Fast [Ca2+] sensor from
Liu et al. 1998 (Activity dependent conductances)
Tom M Morse 20070806

Note that the transition rates depend on the Ca current, ica,
rather than on the membrane voltage.
ENDCOMMENT

NEURON {
	SUFFIX F
	USEION ca READ ica
	RANGE F, M, H
}

UNITS {
	(mA) = (milliamp)
}

PARAMETER {
        G = 10           : p2312 after eqn. 4
	tau_M = 0.5 (ms) : p. 2313, table 2
	tau_H = 1.5 (ms) : table 2 also
	Z_M = 14.2       : table 2 also
	Z_H = 9.8        : table 2 also
}

ASSIGNED {
	Mbar (1)  : Mbar and Hbar play the roles of m_inf, h_inf in
	Hbar (1)  : standard HH models
	ica (mA/cm2)
	F (1)
}

STATE {	M H }

BREAKPOINT {
	SOLVE states METHOD cnexp
	F = G * M * M * H    : note there is no driving force
}

INITIAL {
	: assume that ica has been constant for a long time at startup
	rates(ica)
	M = Mbar
	H = Hbar
}
DERIVATIVE states {
	rates(ica)
	M' = (Mbar - M)/tau_M
	H' = (Hbar - H)/tau_H
}

PROCEDURE rates(ica (mA/cm2)) {
	UNITSOFF
	Mbar = 1/(1+exp( Z_M + 1e3*ica )) : units mA/cm2 is 1e-3*nA/nF when
	Hbar = 1/(1+exp( -Z_H - 1e3*ica )) : specific capacitance= 1 uF/cm2
	UNITSON
}
