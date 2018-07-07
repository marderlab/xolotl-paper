COMMENT
This file, g_cat.mod, implements the sensor equation (3) p. 2311
Liu et al. 1998 (Activity dependent conductances)
for the (fast transient voltage activated) CaT current
Tom M Morse 20070807

ENDCOMMENT

NEURON {
	SUFFIX gbarcat
	POINTER F, S, D
	RANGE gbarcat, tau, Fbar, Sbar, Dbar, A, B, C
: read gbarcat as g bar sub i with i=Cat
: tau is the time constant of activity regulation, and the other
: variables associated with eq. 3 p 2311
:
: below is a value that is expected to be assigned by hoc code
: that is then assigned as a starting value in the INIT block
	RANGE gbarcat_init
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
	gbarcat_init (mA/cm2)
}

INITIAL {
	gbarcat = gbarcat_init
}

STATE { gbarcat (mA/cm2) }

BREAKPOINT {
	SOLVE state METHOD cnexp
}

DERIVATIVE state {
	gbarcat' = ( A*(Fbar-F) + B*(Sbar-S) + C*(Dbar-D) ) * gbarcat / tau
}
