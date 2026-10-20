README
======

Overview
--------

This R code implements a finite-population stochastic individual-based
simulation of the opinion-dynamics model analyzed in the accompanying
study.

The simulation considers a finite population in which each individual
holds one of a set of discrete opinion classes. Individuals update their
opinions through stochastic imitation based on fitness differences.
New opinion classes arise through local mutation between adjacent opinion
classes. Thus, mutation introduces local variation but does not generate
jumps to distant opinions.

The simulation was developed to examine whether the diversification and
polarization observed in the deterministic infinite-population model can
also occur in a finite population under stochastic imitation.


Code origin
-----------

The simulation was originally implemented in C by the authors.

The present R version was produced by machine translation of the original
C code. The translation was intended to preserve the model structure,
parameter values, and updating rules of the original implementation,
while making the simulation easier to read and reproduce in R.

The original C implementation should therefore be regarded as the primary
implementation, and the R version as a translated version provided for
readability and reproducibility.


Model outline
-------------

The default simulation uses:

- Population size: N = 10
- Number of opinion classes: 51
- Opinion range: 0 <= x <= 5
- Initial condition: all individuals at x = 0
- Mutation probability: 10^-6
- Mutation: only between adjacent opinion classes
- Benefit parameter: a = 1
- Social-cost parameter: c = 1
- Assimilation-bias parameter: w = 0.01
- Selection scale: 0.01

At each imitation update:

1. A focal individual and a model individual are selected randomly.
2. The fitness of their respective opinion classes is calculated from
   the benefit, social-cost, and assimilation components of the model.
3. If the model individual has higher fitness, the focal individual
   adopts the model individual's opinion with a probability proportional
   to the positive fitness difference.
4. Mutation is applied independently to each individual. Mutation can
   move an individual only to a neighboring opinion class.

The simulation records the number of individuals in each opinion class
over time.


Purpose
-------

This finite-population simulation is not used to derive the analytical
branching conditions of the model. Rather, it provides a stochastic
finite-population check of the diversification predicted by the
deterministic analysis.

A representative simulation shows that an initially homogeneous finite
population can diversify into distinct opinion groups under stochastic
imitation and local mutation.