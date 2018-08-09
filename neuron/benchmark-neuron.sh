# compile the .mod files
nrnivmodl na.mod cat.mod cas.mod acurrent.mod kca.mod kd.mod hcurrent.mod cad.mod

python test_STG.py