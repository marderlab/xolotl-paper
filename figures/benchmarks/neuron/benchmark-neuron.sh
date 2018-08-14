# make sure you have installed NEURON using these isntructions
# 
# http://andrewdavison.info/notes/installation-neuron-python/
# 
# you have to install from source, otherwise python can't 
# import neuron 

# compile the .mod files
clear
nrnivmodl na.mod cat.mod cas.mod acurrent.mod kca.mod kd.mod hcurrent.mod cad.mod
echo "Compiled NEURON files"

# basic check to make sure things are working
clear
echo "Starting a basic check..."
python test_STG.py


clear
echo "HH model -- varying dt."
python HH_benchmark1.py


clear
echo "HH model -- varying t_end"
python HH_benchmark2.py

clear
echo "HH model -- varying n_comp"
python HH_benchmark3.py


clear
echo "STG model -- varying dt"
python STG_benchmark1.py

clear
echo "STG model -- varying t_end"
python STG_benchmark2.py

clear
echo "STG model -- varying n_comp"
python STG_benchmark3.py