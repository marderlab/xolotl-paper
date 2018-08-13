# make sure you have installed NEURON using these isntructions
# 
# http://andrewdavison.info/notes/installation-neuron-python/
# 
# you have to install from source, otherwise python can't 
# import neuron 

# compile the .mod files
nrnivmodl na.mod cat.mod cas.mod acurrent.mod kca.mod kd.mod hcurrent.mod cad.mod

# basic check to make sure things are working
python test_STG.py

# HH model -- varying dt
python HH_benchmark1.py

# HH mdoel -- varying t_end
python HH_benchmark2.py

# HH mdoel -- varying n_comp
python HH_benchmark3.py