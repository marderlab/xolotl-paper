# NEURON Benchmark Simulations

This document describes how to run the `NEURON` benchmark simulations used to generate
the benchmark figure in Gorur-Shandilya *et al.* 2018.

## Create Custom Version of NEURON
NEURON needs to run with a special binary that includes the conductances specified
in the `.mod` files. In this folder, run

```bash
nrnivmodl acurrent.mod cas.mod cat.mod hcurrent.mod kca.mod kd.mod na.mod cad.mod
```

## Run Each Benchmark Simulation
Pass the name of the python script as an option to `nrniv` with the `-python` flag.
For example, to run `HH_benchmark1.py`

```bash
nrniv -python HH_benchmark1.py
```

This produces a `.csv` file which contains the data output from the benchmark simulation.
