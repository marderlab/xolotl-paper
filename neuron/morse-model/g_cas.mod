COMMENT
This file, g_cas.mod, implements the sensor equation (3) p. 2311
Liu et al. 1998 (Activity dependent conductances)
for the (transient slow voltage activated) CaS current
Tom M Morse 20070807

ENDCOMMENT

NEURON {
	SUFFIX gbarcas
	POINTER F, S, D
	RANGE gbarcas, tau, Fbar, Sbar, Dbar, A, B, C
: read gbarcas as g bar sub i with i=CaS
: tau is the time constant of activity regulation, and the other
: variables associated with eq. 3 p 2311
:
: below is a value that is expected to be assigned by hoc code
: that is then assigned as a starting value in the INIT block
	RANGE gbarcas_init
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
	B = 1
	C = 0
}

ASSIGNED {
	F (1)
	S (1)
	D (1)
	gbarcas_init (mA/cm2)
}

INITIAL {
	gbarcas = gbarcas_init
}

STATE { gbarcas (mA/cm2) }

BREAKPOINT {
	SOLVE state METHOD cnexp
}

DERIVATIVE state {
	gbarcas' = ( A*(Fbar-F) + B*(Sbar-S) + C*(Dbar-D) ) * gbarcas / tau
}
