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

## Module Design [CORDIC_UNIT.v](Design_files/CORDIC_UNIT.v)
The module can work in two modes
1. Trigonometric mode
2. Vector rotation mode
In the _Trigonometric mode_ the _sin_ and _cos_ of the given _angle_ is computed. In the _Vector rotation mode_, inputs _Xi_ and _Yi_ is rotated by the angle provided by the input _angle_

![module](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/module.jpg)

## CORDIC Architecture
A parallel architecture is employed in the design. [add_sub.v](Design_files/add_sub.v) is instantiated inside the Verilog's `generate` block. Parameters N tells the data-width and I-controls the number of iterations to be performed.
The architecture of the single stage is given below:
![archi](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/archi.jpg)

The incrementat/decrement angle is taken from the look-up table given below:
| i   | 2^(-i)      | Angle (Degrees) | Binary Value                                |
|----:|------------:|----------------:|:--------------------------------------------:|
|  0  | 1.000000000 |              45 | 000_11001001000011111101101010100          |
|  1  | 0.500000000 |       26.565051 | 000_01110110101100011001110000010          |
|  2  | 0.250000000 |       14.036243 | 000_00111110101101101110101111110          |
|  3  | 0.125000000 |        7.125016 | 000_00011111110101011011101010011          |
|  4  | 0.062500000 |        3.576334 | 000_00001111111110101010110111011          |
|  5  | 0.031250000 |        1.789911 | 000_00000111111111110101010101101          |
|  6  | 0.015625000 |        0.895174 | 000_00000011111111111110101010101          |
|  7  | 0.007812500 |        0.447614 | 000_00000001111111111111110101010          |
|  8  | 0.003906250 |        0.223811 | 000_00000000111111111111111110101          |
|  9  | 0.001953125 |        0.111906 | 000_00000000011111111111111111110          |
| 10  | 0.000976563 |        0.055953 | 000_00000000001111111111111111111          |
| 11  | 0.000488281 |        0.027976 | 000_00000000000111111111111111111          |
| 12  | 0.000244141 |        0.013988 | 000_00000000000011111111111111111          |
| 13  | 0.000122070 |        0.006994 | 000_00000000000000111111111111111          |
| 14  | 0.000061035 |        0.003497 | 000_00000000000000011111111111111          |
| 15  | 0.000030518 |        0.001749 | 000_00000000000000001111111111111          |
| 16  | 0.000015259 |        0.000874 | 000_00000000000000000111111111111          |
| 17  | 0.000007629 |        0.000437 | 000_00000000000000000011111111111          |
| 18  | 0.000003815 |        0.000219 | 000_00000000000000000001111111111          |
| 19  | 0.000001907 |        0.000109 | 000_00000000000000000000111111111          |
| 20  | 0.000000954 |        0.000055 | 000_00000000000000000000011111111          |
| 21  | 0.000000477 |        0.000027 | 000_00000000000000000000001111111          |
| 22  | 0.000000238 |        0.000014 | 000_00000000000000000000000111111          |
| 23  | 0.000000119 |        0.000007 | 000_00000000000000000000000011111          |
| 24  | 0.000000060 |        0.000004 | 000_00000000000000000000000001111          |
| 25  | 0.000000030 |        0.000002 | 000_00000000000000000000000000111          |
| 26  | 0.000000015 |        0.000001 | 000_00000000000000000000000000011          |
| 27  | 0.000000008 |        0.000001 | 000_00000000000000000000000000001          |
| 28  | 0.000000004 |        0.000000 | 000_00000000000000000000000000000          |

## [Test Bench](Design_files/tb_CORDIC_UNIT.v) and Results
To test the module in both modes following inputs are provided:
```
    trig_rot = 1;
    angle = 32'b001_00001100000101010010001110000; // pi/3(60 degrees)
    
    #200
    trig_rot = 0; 
    angle = 32'b000_10000110000001000001100010010; // pi/6(30 degrees)
    Xi = 32'b000_10110101000001001110011000011; // 1/sqrt(2)
    Yi = 32'b000_10110101000001001110011000011; // 1/sqrt(2)
    #185
    $finish;
```

