# Abstract


Information processing by neurons relies on the transmission and interaction of electrical signals that arise from the biophysics of ion channels and and synapses. Electrophysiological characterization of these low-level mechanisms have  allowed for the construction of conductance-based models that can reproduce many features of neuronal and circuit behavior. However, working with conductance-based models continues to be a challenge due to their high dimensionality, hindering intuition of their dynamical features. Here, we present a neuron and circuit simulator using a novel automatic type system that binds class templates written in C++ to object-oriented code in MATLAB. This approach combines the speed of C++ code with the ease-of-use of scientific programming languages like MATLAB. Neuron models are hierarchical, named and searchable, permitting high-level programmatic control over all parameters. The simulator's architecture allows for the live manipulation of any parameter in any model, and for visualizing the effects of changing that parameter on model behavior. The simulator is fully featured with hundreds of ion channel models from the electrophysiological literature, and can be easily extended to include arbitrary mechanisms and dynamics. Finally, the simulator is written in a modular fashion and has been released under a permissive free software license, enabling it to be integrated easily in third party applications. 


# Introduction 

(Meta note: Introduction should have 3 paragraphs, and go from something very broad to what we did here. Think of the funnel)

## Paragraph 1: what is known, broad introduction 

- conductance based models, HH model 
- challenges in simulating neuron models: OO code, high-dimensional models, language trade-offs (C is fast, but all the cool tools are in in python). highly coupled systems (e.g., in multi-compartment models, all voltages are coupled.)
- previous attempts to write neuron simulators: NEURON, BRIAN, etc
- special integration schemes to work with neurons: Abbot & Dayan's Exponential Euler, the tri-diagonal tricks of NEURON, Crank-Nicholson schemes. 
- what's still missing: something that is simultaneously 1) easy to use 2) fast and efficient 3) easy to interface with scientific programming tools. 


## Paragraph 2: what we did

- wrote cpplab: c++ first automatic type system
- built xolotl that achieves design goals described in previous chapter. 
- some details about this


## Paragraph 3: results 

- outline of rest of paper
- list of things that are very easy to do with xolotl (usage examples)


# Design Goals 

- to make an easy to use, fast simulator in matlab 
- neurons and networks only. no arbitrary dynamical systems
- should be extensible 
- should be usable without ever dipping into the C++ base
- should be a first-class MATLAB object and play nice with the rest of MATLAB

## Features 

0. Neurons, synapses, networks, controllers, conductances...
1. Object oriented code 
2. Automatic Type System that creates strongly typed MATLAB objects that reflect C++ classes without repeating any code. 
3. Automatic compiling 

## Limitations 

1. only conductance based models
2. not suited for large networks (named objects, slow compilation, inefficient object representation)
3. introducing new mechanisms -> write new C++ code

# Usage Examples

- general notes about usage
- how to add things to things (explain how everything is nested)
- how to integrate things
- how to get outputs from the model

## 1 Simulating a HH neuron 

## 2 Performing a voltage clamp experiment in-silico

## 3 Simulating network models 

## 4 Simulating homeostasis regulation of conductances 

## 5 Simulating multi-compartment models 

## 6 Live Manipulation of models


# Benchmarks and Performance 



# Technical Details 

## cpplab 

# Discussion 

## Circumventing Language tradeoffs

## Reproducible Science 