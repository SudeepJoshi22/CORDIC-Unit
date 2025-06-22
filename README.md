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


## Module Design [CORDIC_UNIT_TEMPLATE.v](rtl/CORDIC_UNIT_TEMPLATE.v)
This Verilog file acts as a template for the generated CORDIC-UNIT module.
The CORDIC is designed to work in two modes

1. Rotation Mode
2. Vectoring Mode

## CORDIC Architecture
A pipelined architecture is employed in the design.
`start` signal should be asserted high to start the CORDIC algorithm.
`done` signal will be asserted high when valid output will appear on the output ports. 
The number of clock cycles taken to do one iteration will depend on the `parameter I` value, which can be configured using [Makefile](Makefile).

## How to Generate the design

### Install the CocoTB in Virtual Environment
```
source tools/install_cocotb.sh
```
This script will create a virtual environment and install the cocotb library to run test-bench.

### Only Generate the Design
The Makefile provides three configurable options while generating the RTL.
 - `M`: Number of integer bits.
 - `N`: Number of fractional bits.
 - `ITER`: Number of CORDIC stages(iterations in one CORDIC cycle)

```
make generate 
```
By default M=8, N=23 and ITER=15 is taken as default value

> [!NOTE]
> All the value representation will be taken as Qm.n fixed point value with implicit sign bit. 
> So your total number of bits will be (1 + M + N).
> Make sure that this sum will be equal to 32-bits.

#### Example:
```
make generate M=3 N=28 ITER=29
```

### Generate the Design and run CocoTB test-bench

```
make test
```
```
make test M=3 N=28 ITER=29
```

## [CocoTB Test Bench](cocotb_testbench/test_CORDIC_UNIT.py)
