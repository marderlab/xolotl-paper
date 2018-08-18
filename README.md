# xolotl: An Intuitive and Approachable Neuron & Network Simulator 

This repository contains code, latex documents and supporting images that allows you to reproduce all figures and text in this paper. 

# Status

This paper is now at the "preprint" stage, and has been submitted. You can read it on the arXiv [here](http://biorxiv.org/cgi/content/short/394973v1)


# Structure

The Latex source for the paper is in `paper/`

MATLAB scripts to make every figure in the paper are in `figures/`. You should be able to run each script and it should make the figure exactly as it appears in the paper. 


# Building

## macOS

Using a complete TeX distribution (I used MacTex), `paper.tex` can be compiled using:

1. open `paper.tex` in `TexShop`
2. ⌘ + ⇧ + L
3. ⌘ + ⇧ + B
4. ⌘ + ⇧ + L

(Yes, you have to typeset it twice, first for Latex to figure out which citations you're using, then to insert them)

### Troubleshooting 

If something goes wrong, you are probably missing a package. Try removing all aux files and trying again. 

