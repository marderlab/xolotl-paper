TITLE Slow calcium current
: This is a modification of IT2.mod taken from 
: the Lytton et al. model in ModelDB
: accession number 9889 but which is from other sources (see below)
: to model the I_CaS in Liu et al. 1998 p.2309-2320 (table p.2319)
: Tom Morse
:   Ca++ current responsible for low threshold spikes (LTS)
:   RETICULAR THALAMUS
:   Differential equations
:
:   Model of Huguenard & McCormick, J Neurophysiol 68: 1373-1383, 1992.
:   The kinetics is described by standard equations (NOT GHK)
:   using a m2h format, according to the voltage-clamp data
:   (whole cell patch clamp) of Huguenard & Prince, J Neurosci.
:   12: 3804-3817, 1992.  The model was introduced in Destexhe et al.
:   J. Neurophysiology 72: 803-818, 1994.
:   See http://www.cnl.salk.edu/~alain , http://cns.fmed.ulaval.ca
:   ACTIVATION FUNCTIONS FROM EXPERIMENTS (NO CORRECTION)
:
:   Reversal potential taken from Nernst Equation
:
:   Written by Alain Destexhe, Salk Institute, Sept 18, 1992
:

INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	SUFFIX cas
	USEION ca READ cai WRITE ica
	POINTER gbar
	RANGE m_inf, tau_m, h_inf, tau_h, shift, i, carev
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
	gbar (S/cm2) :	= .00175 (mho/cm2) : modified by activity dependence
: Note: concentrations in Liu et al. paper are in micromolar which needs to be
: converted to millimolar for use in these NEURON programs.  (These mod files
: expect the cai, cao variables to already be in millimolar
: these get overwritten when read in:
	cai (mM) :	= 2.4e-4 (mM)		: adjusted for eca=120 mV
	cao	= 3	(mM)  : p.2319 Liu et al. 1998 (for eca 120 comment above cao=2 mM (orig))
}

STATE {
	m h
}

ASSIGNED {
	ica	(mA/cm2)
	i	(mA/cm2)
	carev	(mV) : Ca^2+ reversal potential
	m_inf
	tau_m	(ms)
	h_inf
	tau_h	(ms)
        celsius (degC)
}

BREAKPOINT {
	SOLVE castate METHOD cnexp
	UNITSOFF
	carev = (1e3) * (R*(celsius+273.15))/(2*FARADAY) * log (cao/cai)
	UNITSON
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
	m = m_inf
	h = h_inf
}

PROCEDURE evaluate_fct(v(mV)) { 
	m_inf= 1.0 / (1+exp( -(v+33)/8.1 ))
	h_inf= 1.0 / (1+exp( (v+60)/6.2 ))

: note that I thought that fig 10 p 2319 tau_m column, I_CaS row started with 14
: however it is 1.4 instead (there is a sneaky decimal point on that one! - TMM 20070802:
	tau_m =  1.4 + 7 / ( exp( (v+27)/10 ) +exp( -(v+70)/13 ) )
	tau_h =  60 + 150 / ( exp( (v+55)/9 ) + exp( -(v+65)/16 ) )
}
UNITSON
