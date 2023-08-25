# CORDIC Unit Design using Verilog HDL

## Introduction to CORDIC Algorithm
**CORDIC (COordinate Rotation DIgital Computer)** is an iterative algorithm which allows us to calculate trignometric functions, vector rotations, complex multiplication and division, hyperbolic functions
and many more efficiently in digital hardware.
One of the common applications can be found in **DSP(Digital Signal Processing)** hardwares.

## Iterative Equations of CORDIC
![equations](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Screenshot%20from%202023-08-26%2000-49-17.png)

This iterative equations rotates the vector (x,y) by an angle. The σ is the sign decided by looking at the z[i+1]'s sign. The angle to be rotated is fed into z[0] and after N number of iterations if the results are scaled by the scaling factor K = 0.6072, the rotated vector is obtained.
![rotations](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Screenshot%20from%202023-08-26%2000-49-57.png)	

## Choosing the fixed-point representation format
As most of the DSP processors are 32-bit, 32-bit representation is used. To represent integers(decimal +  fraction) in binary Qm.n fixed-point representation is employed in most of the processors. 'm' represents the number of bits to indicate decimal part(including sign bit) and 'n' represents the number of bits used to represent fractional part.
In the design **Q3.29** representation is chosen. 29-bits for fractional part to provide higher precision in the fractional part.

