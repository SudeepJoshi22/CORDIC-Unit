import os
import random
import sys
import math
from pathlib import Path

from Q_m_n_conversions import *

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.regression import TestFactory

M = int(os.environ["M"])
N = int(os.environ["N"])
Q_TOTAL = 1 + M + N
iterations = int(os.environ["ITER"])

with open('cordic_k', 'r') as f:
    K = f.read()
K = float(K)

@cocotb.test
async def test_CORDIC_UNIT(dut):

    await test_rotation_45deg(dut)

    await test_rotate_full_quadrant(dut)

    await test_vectoring(dut)

    cocotb.log.info("Directed Tests Passed!")

    #await random_test(dut, N=10)

    #cocotb.log.info("Random Tests Passed!")

async def reset_dut(dut):
    dut.rst_n.value = 0
    await Timer(10, units='ns')
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

async def test_rotation_45deg(dut):
    """
    Test CORDIC rotation: rotate (1.0, 0.0) by +45 degrees (~0.785398) in rotation mode.
    Expect ~ (0.7071, 0.7071) and Zr ~ 0.
    """
    # Launch clock
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())

    # Reset
    await reset_dut(dut)

    # Prepare inputs
    x_in = 1.0
    y_in = 0.0
    z_in = 0.785398  # ~45 degrees in radians
    rot_vec = 0      # Rotation mode

    # Convert to Q-format packed ints
    x_bits, x_int = to_q_format(x_in, M, N)
    y_bits, y_int = to_q_format(y_in, M, N)
    z_bits, z_int = to_q_format(z_in, M, N)

    print(f"\tInput Values Xi : {x_bits} int: {hex(x_int)}")
    print(f"\tInput Values Yi : {y_bits} int: {hex(y_int)}")
    print(f"\tInput Values Zi : {z_bits} int: {hex(z_int)}")
    
    # Drive inputs
    dut.Xi.value    = x_int
    dut.Yi.value    = y_int
    dut.Zi.value    = z_int

## [CocoTB Test Bench](cocotb_testbench/test_CORDIC_UNIT.py)

Using Python math libraries and inerconversions between float and Qm.n fixed-values using []
    dut.rot_vec.value   = rot_vec

    # Pulse start
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    # Wait for done
    while True:
        await RisingEdge(dut.clk)
        if dut.done.value == 1:
            break

    # Sample outputs
    xr_int = dut.Xr.value
    yr_int = dut.Yr.value
    zr_int = dut.Zr.value

    print(f"\tFinal Values: Xr : {xr_int}, Yr : {yr_int}, Zr : {zr_int}")
    # Convert back to floats
    xr = from_q_format(format(xr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    yr = from_q_format(format(yr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    zr = from_q_format(format(zr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)

    # Expected results
    expected_x = 0.7071 * K
    expected_y = 0.7071 * K
    expected_z = 0.0

    # Tolerance
    tol = 1e-4

    print(f"\tdiff X : {abs(xr - expected_x)}")
    print(f"\tdiff Y : {abs(yr - expected_y)}")
    print(f"\tdiff Z : {abs(zr - expected_z)}")

    assert abs(xr - expected_x) <= tol, f"Xr = {xr}, expected ~ {expected_x}"
    assert abs(yr - expected_y) <= tol, f"Yr = {yr}, expected ~ {expected_y}"
    assert abs(zr - expected_z) <= tol, f"Zr = {zr}, expected ~ {expected_z}"

    x_correct = xr / K
    y_correct = yr / K

    dut._log.info(f"Actual Final Values: Xr={xr}, Yr={yr}, Zr={zr}")
    dut._log.info(f"Scaling Factor Corrected Final Values: Xr={x_correct}, Yr={y_correct}")

async def test_rotate_full_quadrant(dut):
    """
    Tests by rotating the (0,0) vector from 0 degrees to 90 degress
    """
    for angle in range(0,95,5):
        dut._log.info(f"Rotating (1,0) by the angle {angle}")
        angle_rad, cos, sin = gen_radian(angle)
        (xr, yr, zr) = await rotate_vector_modes(dut, 1.0, 0.0, angle_rad, 0)

        xr_corrected = xr / K
        yr_corrected = yr / K

        dut._log.info(f"\tXr Corrected : {xr_corrected}, Yr Corrected : {yr_corrected}")
        dut._log.info(f"\tcos({angle}) = {cos}, sin({angle}) = {sin}\n")

async def test_vectoring(dut):
    """
    Tests by driving CORDIC in Vectoring mode with different values
    """
    x = -2
    y = -2
    while x <= 2:
        if x == 0:
                x += 0.25
                continue
        while y <= 2:
            
            # Zin is being set to zero
            dut._log.info(f"Vectoring ({x},{y})") 

            (x_v, y_v, z_v) = await rotate_vector_modes(dut, x, y, 0, 1)
            dut._log.info(f"\tFinal Values After Vectoring X_f = {x_v}, Y_f = {y_v}, Z_f = {z_v}") 
            
            (x_f, y_f, z_f) = vector_equation(x, y, 0)
            dut._log.info(f"\tExpected final values in Vectoring mode: x_f = {x_f} y_f = {y_f} z_f = {z_f}\n")
            
            y += 0.25
        x += 0.25
        y = -2

async def rotate_vector_modes(dut, x_in, y_in, z_in, rot_vec):
    """
    Rotates the vector (x_in, y_in) by the angle z_in taken as radians
    """

    # Convert to Q-format packed ints
    x_bits, x_int = to_q_format(x_in, M, N)
    y_bits, y_int = to_q_format(y_in, M, N)
    z_bits, z_int = to_q_format(z_in, M, N)

    dut._log.info(f"\tInput Values Xi : {x_bits} int: {hex(x_int)}")
    dut._log.info(f"\tInput Values Yi : {y_bits} int: {hex(y_int)}")
    dut._log.info(f"\tInput Values Zi : {z_bits} int: {hex(z_int)}")
    
    # Drive inputs
    dut.Xi.value    = x_int
    dut.Yi.value    = y_int
    dut.Zi.value    = z_int    
    dut.rot_vec.value   = rot_vec

    # Pulse start
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    # Wait for done
    while True:
        await RisingEdge(dut.clk)
        if dut.done.value == 1:
            break

    # Sample outputs
    xr_int = dut.Xr.value
    yr_int = dut.Yr.value
    zr_int = dut.Zr.value

    dut._log.info(f"\tFinal Values: Xr : {xr_int}, Yr : {yr_int}, Zr : {zr_int}\n")
    # Convert back to floats
    xr = from_q_format(format(xr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    yr = from_q_format(format(yr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    zr = from_q_format(format(zr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    
    #corrected_x = xr * K
    #corrected_y = yr * K
    
    return xr, yr, zr
    #dut._log.info(f"\tFinal Corrected Values = X: {corrected_x} Y: {corrected_y}\n")


#async linear(dut, x_in, y_in, z_in):



def gen_radian(angle):
    """
    Returns the angle in radians and cos and sin value of the angle
    """
    angle_rad = math.radians(angle)
    cos = math.cos(angle_rad)
    sin = math.sin(angle_rad)

    return angle_rad, cos, sin

def vector_equation(x_in, y_in, z_in):
    """
    Returns the values of Vectoring mode equation final values
    """
    x_f = K * math.sqrt( x_in**2 + y_in**2)
    y_f = 0.0
    z_f = z_in + math.atan(y_in / x_in)

    return x_f, y_f, z_f

def run_tests():

    factory = TestFactor(test_CORDIC_UNIT)
    factory.generate_tests()

            
if __name__ == "__main__":

    run_tests()
