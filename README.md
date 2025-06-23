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
This script will create a virtual environment and install the cocotb library to run the test-bench.

### Only Generate the Design
The Makefile provides three configurable options while generating the RTL.
 - `M`: Number of integer bits.
 - `N`: Number of fractional bits.
 - `ITER`: Number of CORDIC stages(iterations in one CORDIC cycle)

```
make generate 
```
M=8, N=23 and ITER=15 is taken as default value

> [!NOTE]
> All the value representation will be taken as Qm.n fixed point value with implicit sign bit. 
> So your total number of bits will be (1 + M + N).
> Make sure that this sum will be equal to 32-bits.

#### Example:
```
make generate M=3 N=28 ITER=29
```

### Generate the Design and run CocoTB test-bench

> [!NOTE]
> Make sure to activate the virtual environment before running the CocoTB Test-Bench.
> ``` source venv/bin/activate ```

```
make test
```
```
make test M=3 N=28 ITER=29
```

## [CocoTB Test Bench](cocotb_testbench/test_CORDIC_UNIT.py)

Using Python math libraries and inerconversions between float and Qm.n fixed-values using [Q_m_n_conversions.py](cocotb_testbench/Q_m_n_conversions.py) tests are written in CocoTB environment to test the CORDIC with full quadrant inputs and check the values with expected values side-by-side.

#### Tests include
- **test_rotation_45_deg()** : Rotates the (1,0) with 45 degrees, the expected values will be cos(45) and sin(45), which will be compared for the defined error tolerence of 1e-4.
- **test_rotate_full_quadrant()** : Rotates the (1,0) from 0 to 90 degrees with the increment of 5 deg.
- **test_vectoring()** : Tests the CORDIC in vectoring from values ranging from (-2,2) for Xin and Yin with Zin kept as zero. The test will displays the calculated and expected values side-by-side.

## Project Creator

Sudeep Joshi - sudeepj881@gmail.com

Project Link: [CORDIC-Unit](https://github.com/SudeepJoshi22)

LinkdIn: [Sudeep Joshi](https://www.linkedin.com/in/sudeep-joshi-569951207/)

