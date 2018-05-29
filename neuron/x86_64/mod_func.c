#include <stdio.h>
#include "hocdec.h"
extern int nrnmpi_myid;
extern int nrn_nobanner_;

extern void _na_reg(void);
extern void _kd_reg(void);

void modl_reg(){
  if (!nrn_nobanner_) if (nrnmpi_myid < 1) {
    fprintf(stderr, "Additional mechanisms from files\n");

    fprintf(stderr," na.mod");
    fprintf(stderr," kd.mod");
    fprintf(stderr, "\n");
  }
  _na_reg();
  _kd_reg();
}
