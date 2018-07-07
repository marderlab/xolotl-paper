#include <stdio.h>
#include "hocdec.h"
extern int nrnmpi_myid;
extern int nrn_nobanner_;

extern void _ka_reg(void);
extern void _cas_reg(void);
extern void _cat_reg(void);
extern void _h_reg(void);
extern void _kca_reg(void);
extern void _kd_reg(void);
extern void _na_reg(void);
extern void _cadecay_reg(void);

void modl_reg(){
  if (!nrn_nobanner_) if (nrnmpi_myid < 1) {
    fprintf(stderr, "Additional mechanisms from files\n");

    fprintf(stderr," ka.mod");
    fprintf(stderr," cas.mod");
    fprintf(stderr," cat.mod");
    fprintf(stderr," h.mod");
    fprintf(stderr," kca.mod");
    fprintf(stderr," kd.mod");
    fprintf(stderr," na.mod");
    fprintf(stderr," cadecay.mod");
    fprintf(stderr, "\n");
  }
  _ka_reg();
  _cas_reg();
  _cat_reg();
  _h_reg();
  _kca_reg();
  _kd_reg();
  _na_reg();
  _cadecay_reg();
}
