# CORDIC Unit Design using Verilog HDL

## Introduction to CORDIC Algorithm
**CORDIC (COordinate Rotation DIgital Computer)** is an iterative algorithm which is used to calculate trignometric functions, vector rotations, complex multiplication and division, hyperbolic functions
and many more in digital hardware with efficiency.
One of the common applications can be found in **DSP(Digital Signal Processing)** hardwares.

## Iterative Equations of CORDIC
![equations](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Screenshot%20from%202023-08-26%2000-49-17.png)

These iterative equations rotates the vector (x,y) by the given angle angle. 'σ' is the sign of z[i+1]. The angle to be rotated is initialized into z[0] and after N number of iterations, the rotated vector is obtained which is scaled by a factor of K = 0.6072 .
![rotations](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Screenshot%20from%202023-08-26%2000-49-57.png)	

Reference: (https://www.allaboutcircuits.com/technical-articles/an-introduction-to-the-cordic-algorithm/)

## Choosing the fixed-point representation format
As most of the DSP processors are 32-bit, 32-bit representation is used here. To represent integers(decimal +  fraction) in binary, Qm.n fixed-point representation is employed in most of the processors. Where 'm' represents the number of bits used to indicate decimal part(including sign bit) and 'n' represents the number of bits used to represent fractional part.
In the design **Q3.29** representation is chosen. 29-bits for fractional part to provide high resolution to the fractional part.

## Module Design [CORDIC_UNIT.v](Design_files/CORDIC_UNIT.v)
The module can work in two modes
1. Trigonometric mode
2. Vector rotation mode

In the *Trigonometric mode* (`trig_rot = 1`) the *sin* and *cos* of the given *angle* is computed. In the _Vector rotation mode_.(`trig_rot = 0`) , inputs *Xi* and *Yi* are rotated by the angle provided by the input *angle*

![module](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/module.jpg)

## CORDIC Architecture
A parallel architecture is employed in the design. [add_sub.v](Design_files/add_sub.v) is instantiated inside the Verilog's `generate` block. Parameter N tells the data-width and I-controls the number of iterations to be performed.
The architecture of the single stage is given below:
![archi](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/archi.jpg)

The incrementat/decrement angle( arctan(2^(-i)) ) is taken from the look-up table given below:
| i   | 2^(-i)      | Angle (Degrees) | Binary Value                                |
|----:|------------:|----------------:|:--------------------------------------------:|
|  0  | 1.000000000 |              45 | 32'b0000_1100100100001111110110101010       |
|  1  | 0.500000000 |       26.565051 | 32'b0000_0111011010110001100111000001       |
|  2  | 0.250000000 |       14.036243 | 32'b0000_0011111010110110111010111111       |
|  3  | 0.125000000 |        7.125016 | 32'b0000_0001111111010101101110101001       |
|  4  | 0.062500000 |        3.576334 | 32'b0000_0000111111111010101011011101       |
|  5  | 0.031250000 |        1.789911 | 32'b0000_0000011111111111010101010110       |
|  6  | 0.015625000 |        0.895174 | 32'b0000_0000001111111111111010101010       |
|  7  | 0.007812500 |        0.447614 | 32'b0000_0000000111111111111111010101       |
|  8  | 0.003906250 |        0.223811 | 32'b0000_0000000011111111111111111010       |
|  9  | 0.001953125 |        0.111906 | 32'b0000_0000000001111111111111111111       |
| 10  | 0.000976563 |        0.055953 | 32'b0000_0000000000111111111111111111       |
| 11  | 0.000488281 |        0.027976 | 32'b0000_0000000000011111111111111111       |
| 12  | 0.000244141 |        0.013988 | 32'b0000_0000000000001111111111111111       |
| 13  | 0.000122070 |        0.006994 | 32'b0000_0000000000000111111111111111       |
| 14  | 0.000061035 |        0.003497 | 32'b0000_0000000000000011111111111111       |
| 15  | 0.000030518 |        0.001749 | 32'b0000_0000000000000001111111111111       |
| 16  | 0.000015259 |        0.000874 | 32'b0000_0000000000000000111111111111       |
| 17  | 0.000007629 |        0.000437 | 32'b0000_0000000000000000011111111111       |
| 18  | 0.000003815 |        0.000219 | 32'b0000_0000000000000000001111111111       |
| 19  | 0.000001907 |        0.000109 | 32'b0000_0000000000000000000111111111       |
| 20  | 0.000000954 |        0.000055 | 32'b0000_0000000000000000000011111111       |
| 21  | 0.000000477 |        0.000027 | 32'b0000_0000000000000000000001111111       |
| 22  | 0.000000238 |        0.000014 | 32'b0000_0000000000000000000000111111       |
| 23  | 0.000000119 |        0.000007 | 32'b0000_0000000000000000000000011111       |
| 24  | 0.000000060 |        0.000004 | 32'b0000_0000000000000000000000001111       |
| 25  | 0.000000030 |        0.000002 | 32'b0000_0000000000000000000000000111       |
| 26  | 0.000000015 |        0.000001 | 32'b0000_0000000000000000000000000011       |
| 27  | 0.000000008 |        0.000001 | 32'b0000_0000000000000000000000000001       |
| 28  | 0.000000004 |        0.000000 | 32'b0000_0000000000000000000000000000       |


## [Test Bench](Design_files/tb_CORDIC_UNIT.v) and Results
To test the module in both modes following inputs are provided:
```
    trig_rot = 1;
    angle = 32'b001_00001100000101010010001110000; // pi/3(60 degrees)
    
    #200
    trig_rot = 0; 
    angle = 32'b000_01000011000001010100100100001; // pi/12 (15 degrees)
    Xi = 32'b000_10110101000001001110011000011; // 1/sqrt(2)
    Yi = 32'b000_10110101000001001110011000011; // 1/sqrt(2)
    #185
    $finish;
```

The expected outputs for these are _cos(60)/0.6072 = 0.82345191_ and _sin(60)/0.6072 = 1.426260546_
(scaling correction is not employed currently)

![output](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/output.png)
![output](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Screenshot%20from%202023-08-26%2003-07-10.png)

Cos:
![cos](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/cos.png)

Sin:
![sin](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/sin.png)

Xr:
![xr](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Xr.png)

Yr:
![yr](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Yr.png)


## YOSYS Synthesis
![yosys1](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Screenshot%20from%202023-08-25%2023-59-42.png)
![yosys2](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/Screenshot%20from%202023-08-26%2000-05-20.png)

## [Netlist dot file](netlist.ps) (very large to show in image)

## Netlist simulation
![post](https://github.com/SudeepJoshi22/SynthoSphere_CORDIC_Unit/blob/main/images/post.png)
Matching with the pre-synthesis result

