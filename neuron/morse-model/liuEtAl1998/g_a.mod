COMMENT
This file, g_a.mod, implements the sensor equation (3) p. 2311
Liu et al. 1998 (Activity dependent conductances)
for the (transient potassium) A current
Tom M Morse 20070807

ENDCOMMENT

NEURON {
	SUFFIX gbara
	POINTER F, S, D
	RANGE gbara, tau, Fbar, Sbar, Dbar, A, B, C
: read gbara as g bar sub i with i=A
: tau is the time constant of activity regulation, and the other
: variables associated with eq. 3 p 2311
:
: below is a value that is expected to be assigned by hoc code
: that is then assigned as a starting value in the INIT block
	RANGE gbara_init
}

UNITS {
	(mA) = (milliamp)
}

PARAMETER {
	Fbar = 0.1 (1) : p2312 col 1 paragraph below middle of page
	Sbar = 0.1 (1)
	Dbar = 0.1 (1)
	tau = 5000 (ms) : p2312 col 1 paragraph at middle of page
	A = 0 : p2312, Table 1
	B = -1
	C = -1
}

ASSIGNED {
	F (1)
	S (1)
	D (1)
	gbara_init (mA/cm2)
}

INITIAL {
	gbara = gbara_init
}

STATE { gbara (mA/cm2) }

BREAKPOINT {
	SOLVE state METHOD cnexp
}

DERIVATIVE state {
	gbara' = ( A*(Fbar-F) + B*(Sbar-S) + C*(Dbar-D) ) * gbara / tau
}
