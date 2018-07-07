COMMENT
This file, g_kd.mod, implements the sensor equation (3) p. 2311
Liu et al. 1998 (Activity dependent conductances)
for the (usual delayed rectifier) Kd current
Tom M Morse 20070807

ENDCOMMENT

NEURON {
	SUFFIX gbarkd
	POINTER F, S, D
	RANGE gbarkd, tau, Fbar, Sbar, Dbar, A, B, C
: read gbarkd as g bar sub i with i=Kd
: tau is the time constant of activity regulation, and the other
: variables associated with eq. 3 p 2311
:
: below is a value that is expected to be assigned by hoc code
: that is then assigned as a starting value in the INIT block
	RANGE gbarkd_init
}

UNITS {
	(mA) = (milliamp)
}

PARAMETER {
	Fbar = 0.1 (1) : p2312 col 1 paragraph below middle of page
	Sbar = 0.1 (1)
	Dbar = 0.1 (1)
	tau = 5000 (ms) : p2312 col 1 paragraph at middle of page
	A = 1 : p2312, Table 1
	B = -1
	C = 0
}

ASSIGNED {
	F (1)
	S (1)
	D (1)
	gbarkd_init (mA/cm2)
}

INITIAL {
	gbarkd = gbarkd_init
}

STATE { gbarkd (mA/cm2) }

BREAKPOINT {
	SOLVE state METHOD cnexp
}

DERIVATIVE state {
	gbarkd' = ( A*(Fbar-F) + B*(Sbar-S) + C*(Dbar-D) ) * gbarkd / tau
}
