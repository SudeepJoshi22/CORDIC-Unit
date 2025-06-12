import os
import random
import sys
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

    print(f"Input Values Xi : {x_bits} int: {hex(x_int)}")
    print(f"Input Values Yi : {y_bits} int: {hex(y_int)}")
    print(f"Input Values Zi : {z_bits} int: {hex(z_int)}")
    
    # Drive inputs
    dut.Xi.value 	= x_int
    dut.Yi.value	= y_int
    dut.Zi.value	= z_int
    dut.rot_vec.value	= rot_vec

    # Pulse start
    dut.start.value	= 1
    await RisingEdge(dut.clk)
    dut.start.value	= 0

    # Wait for done
    while True:
        await RisingEdge(dut.clk)
        if dut.done.value == 1:
            break

    # Sample outputs
    xr_int = dut.Xr.value
    yr_int = dut.Yr.value
    zr_int = dut.Zr.value

    print(f"Final Values: Xr : {xr_int}, Yr : {yr_int}, Zr : {zr_int}")
    # Convert back to floats
    xr = from_q_format(format(xr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    yr = from_q_format(format(yr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    zr = from_q_format(format(zr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)

    # Expected results
    expected_x = 0.7071 / K
    expected_y = 0.7071 / K
    expected_z = 0.0

    # Tolerance
    tol = 1e-3
   
    assert abs(xr - expected_x) <= tol, f"Xr = {xr}, expected ~ {expected_x}"
    assert abs(yr - expected_y) <= tol, f"Yr = {yr}, expected ~ {expected_y}"
    assert abs(zr - expected_z) <= tol, f"Zr = {zr}, expected ~ {expected_z}"

    x_correct = xr * K
    y_correct = yr * K

    dut._log.info(f"Actual Final Values: Xr={xr}, Yr={yr}, Zr={zr}")
    dut._log.info(f"Scaling Factor Corrected Final Values: Xr={x_correct}, Yr={y_correct}")
    dut._log.info(f"Rotation test passed")


def run_tests():

    factory = TestFactor(test_CORDIC_UNIT)
    factory.generate_tests()

            
if __name__ == "__main__":

    run_tests()
