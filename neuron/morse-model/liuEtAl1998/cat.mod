TITLE Low threshold calcium current
: This is a modification of IT2.mod taken from 
: the Lytton et al. model in ModelDB
: accession number 9889 but which is from other sources (see below)
: to model the I_CaT in Liu et al. 1998
: Tom M Morse 20070803
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
:
:   ACTIVATION FUNCTIONS FROM EXPERIMENTS (NO CORRECTION)
:
:   Reversal potential taken from Nernst Equation
:
:   Written by Alain Destexhe, Salk Institute, Sept 18, 1992
:

INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	SUFFIX cat
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
:	celsius	= 36	(degC)
:	eca	= 120	(mV)
	gbar (S/cm2) := .00175 (mho/cm2)
:	shift	= 2 	(mV)		: screening charge for Ca_o = 2 mM
	cai  (mM) : = 2.4e-4 (mM)		: adjusted for eca=120 mV
                                        : p.2319 Liu et al. 1998
	cao	= 3	(mM)            : original 2 (mM)
}

STATE {
	m h
}

ASSIGNED {
	ica	(mA/cm2)
	i	(mA/cm2)
	carev	(mV)
	m_inf
	tau_m	(ms)
	h_inf
	tau_h	(ms)
        celsius (degC)
}

BREAKPOINT {
	SOLVE castate METHOD cnexp
	carev = (1e3) * (R*(celsius+273.15))/(2*FARADAY) * log (cao/cai)
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

	m_inf= 1.0 / (1+exp( -(v+27.1)/7.2 ))
	h_inf= 1.0 / (1+exp( (v+32.1)/5.5 ))

	tau_m =  21.7 - 21.3 / (1+exp( -(v+68.1)/20.5 ))
	tau_h =  105 - 89.8 / (1+exp( -(v+55)/16.9 ))

}
UNITSON
