# CORDIC Unit Design using Verilog HDL

## Introduction to CORDIC Algorithm
**CORDIC (COordinate Rotation DIgital Computer)** is an iterative algorithm which allows us to calculate trignometric functions, vector rotations, complex multiplication and division, hyperbolic functions
and many more efficiently in digital hardware.
One of the common applications can be found in **DSP(Digital Signal Processing)** hardwares.

## Iterative Equations of CORDIC
x[i+1]=x[i]−σi2−iy[i]

y[i+1]=y[i]+σi2−ix[i]

z[i+1]=z[i]−σitan−1(2−i)


