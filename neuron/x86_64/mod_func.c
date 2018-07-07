#include <stdio.h>
#include "hocdec.h"
extern int nrnmpi_myid;
extern int nrn_nobanner_;

extern void _acurrent_reg(void);
extern void _cas_reg(void);
extern void _cat_reg(void);
extern void _hcurrent_reg(void);
extern void _kca_reg(void);
extern void _kd_reg(void);
extern void _na_reg(void);
extern void _cad_reg(void);

void modl_reg(){
  if (!nrn_nobanner_) if (nrnmpi_myid < 1) {
    fprintf(stderr, "Additional mechanisms from files\n");

    fprintf(stderr," acurrent.mod");
    fprintf(stderr," cas.mod");
    fprintf(stderr," cat.mod");
    fprintf(stderr," hcurrent.mod");
    fprintf(stderr," kca.mod");
    fprintf(stderr," kd.mod");
    fprintf(stderr," na.mod");
    fprintf(stderr," cad.mod");
    fprintf(stderr, "\n");
  }
  _acurrent_reg();
  _cas_reg();
  _cat_reg();
  _hcurrent_reg();
  _kca_reg();
  _kd_reg();
  _na_reg();
  _cad_reg();
}
