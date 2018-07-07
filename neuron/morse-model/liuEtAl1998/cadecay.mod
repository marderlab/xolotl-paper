TITLE Calcium decay

: change in time constant, and the factor that multiplies ica
: to match Liu et al. 1998 p2319 last eqn. and paragraph. Tom M Morse 20070802
: modified from cadecay.mod file in ModelDB accession number 2733
: as described in Bhalla and Bower, J. Neurophysiol. 69:1948-1983 (1993)
: written by Andrew Davison
: partially based on cadecay.mod by Alain Destexhe, Salk Institute 1995.
: 25-08-98

INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms) }

NEURON{
	SUFFIX cad
	USEION ca READ ica, cai WRITE cai
	RANGE ica, channel_flow, depth, B
	GLOBAL cai, tau, cainf, setB
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(molar) = (1/liter)
	(mM) = (millimolar)
	(um) = (micron)
}

CONSTANT {
        FARADAY=96485.309   : matches current value in NEURON -TMM
}

PARAMETER {
	dt (ms)
        depth = 1 (um)       : default value of 1 for ica multiplying const.
	tau = 20 	(ms) : 10 was Davison's cai decay const. -TMM 20070802
	cainf = 5e-5	(mM) : 1e-5 was Davison's baseline [Ca2+] conc. -TMM "
	ica		(mA/cm2)
        setB = -4.7e-2 (cm2 mM/mA/ms)
}

STATE {
	cai		(mM)
}

INITIAL {
	cai = cainf
        B = -4.7e-2 : papers -0.94/20
}

ASSIGNED {
	channel_flow	(mM/ms)
	B		(mM cm2/ms/mA)
}

BREAKPOINT {
	SOLVE state METHOD cnexp
}

DERIVATIVE state {
:	B = -(1e4)/(2*FARADAY*depth) : Daivson et al.'s way of computing
:       note that the value of the above is aprox -5.18e-2
        B = setB
	channel_flow = B*ica
	if (channel_flow <= 0.0 ) { channel_flow = 0.0 }	: one way flow in channel
	cai' = channel_flow  - (cai - cainf)/tau
COMMENT
Compute the relative Ca shell size between Davison (Bhalla and Bower) and
Liu et al. 1998. From the way that Davison et al. calculate B there in

cai'=B * ica - (cai-cainf)/tau

there is an implicit factor of tau e.g.

B= b_D/tau_D = -5.18e-2

In Davison tau = tau_D (_D to keep straight from Liu et al.)=10
In Liu et al. tau_L=20 and B = B_L=b_L/tau_L=-.94/20=-4.7e-2

Therefore the b_'s are
b_D=-.518
b_L=-.94

since b=-(1e4)/(2*FARADAY*depth) i.e. inversely proportional to depth

b_L/b_D = -.94/-.518 = 1.8146718
depth_D/depth_L = 1.8147
depth_L/depth_D = .55

Davison sets depth to 1 um which implies the Liu et al. depth is 
0.55 um.

ENDCOMMENT
COMMENT
A note on units: The term in the last equation in the paper on Ca
diffusion (rearranged to include the time const. as implemented here):

-0.94 uM ica
----- --
  20  ms

when written in NEURON will need the ica units in NEURON (mA/cm2)
converted to the papers (nA/nF) however

mA  1nA      area_cm2     nA
--  -------  -------- = 1 --
cm2 1e-3 mA  0.628 nF     nF

where area_cm2 is the area of the cell in cm squared and 0.628 nF is
the capacitance of the cell.  So the factor being 1, doesn't need to be
written.  Also note that there is a factor for each term in the 
eqn., of (1e-3 mM)/uM converting each term from uM to mM that since is 
common also doesn't have to be written.

ENDCOMMENT
}
