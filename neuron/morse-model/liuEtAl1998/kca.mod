COMMENT
This file, kca.mod, implements the IKCa potassium current from 
Liu et al. 1998 (Activity dependent conductances) table p.2319
Tom M Morse 20070803
ENDCOMMENT

NEURON {
	SUFFIX kca
	NONSPECIFIC_CURRENT i
	USEION ca READ cai
	POINTER gbar
	RANGE i, Erev
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(molar) = (1/liter)
	(mM) = (millimolar)
	(um) = (micron)
	(S)  = (siemens)
}

PARAMETER {
	gbar (S/cm2) : = 2e-6	(S/cm2) < 0, 1e9 > : this value gets overwritten by activity dependent regulation
	Erev = -80 (mV)
: Note: concentrations in Liu et al. paper are in micromolar which needs to be
: converted to millimolar for use in these NEURON programs.  (These mod files
: expect the cai, cao variables to already be in millimolar
: these get overwritten when read in:
	cai (mM) :	= 2.4e-4 (mM)		: adjusted for eca=120 mV
	cao	= 3	(mM)  : p.2319 Liu et al. 1998 (for eca 120 comment above cao=2 mM (orig))
}

ASSIGNED {
	i (mA/cm2)
	v (mV)
	g (S/cm2)
	minf
	tau_m (ms)
}

STATE {	m }

BREAKPOINT {
	SOLVE states METHOD cnexp
	g = gbar * m^4
	i = g * (v - Erev)
}

INITIAL {
	: assume that v has been constant for a long time
	rates(v)
	m = minf
}
DERIVATIVE states {
	rates(v)
	m' = (minf - m)/tau_m
}

FUNCTION taum(Vm (mV)) (ms) {
	UNITSOFF
	taum = 90.3-75.1/(1+exp(-(Vm+46)/22.7))
	UNITSON
}

PROCEDURE rates(Vm(mV)) {
	tau_m = taum(Vm)
	UNITSOFF
: note the conversion of 3 uM (paper p. 2319 fig 10) to 3e-3 mM in below:
	minf = (cai/(cai+3e-3)) * (1/(1+exp(-(Vm+28.3)/12.6)))
	UNITSON
}
