import os
import random
import sys
from pathlib import Path

from Q_m_n_conversions import *

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.regression import TestFactory



@cocotb.test
async def test_CORDIC_UNIT(dut):

    await test_rotation_45deg(dut)

    coctb.log.info("Directed Tests Passed!")

    #await random_test(dut, N=10)

    #cocotb.log.info("Random Tests Passed!")

async def reset_dut(dut):
    dut.rst_n <= 0
    await Timer(10, units='ns')
    dut.rst_n <= 1
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

    # Drive inputs
    dut.Xi <= x_int
    dut.Yi <= y_int
    dut.Zi <= z_int
    dut.rot_vec <= rot_vec

    # Pulse start
    dut.start <= 1
    await RisingEdge(dut.clk)
    dut.start <= 0

    # Wait for done
    while True:
        await RisingEdge(dut.clk)
        if dut.done.value.integer == 1:
            break

    # Sample outputs
    xr_int = dut.Xr.value.signed_integer
    yr_int = dut.Yr.value.signed_integer
    zr_int = dut.Zr.value.signed_integer

    # Convert back to floats
    xr = from_q_format(format(xr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    yr = from_q_format(format(yr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)
    zr = from_q_format(format(zr_int & ((1<<Q_TOTAL)-1), f'0{Q_TOTAL}b'), M, N)

    # Expected results
    expected_x = 0.7071
    expected_y = 0.7071
    expected_z = 0.0

    # Tolerance
    tol = 1e-3

    if abs(xr - expected_x) > tol:
        raise TestFailure(f"Xr = {xr}, expected ~ {expected_x}")
    if abs(yr - expected_y) > tol:
        raise TestFailure(f"Yr = {yr}, expected ~ {expected_y}")
    if abs(zr - expected_z) > tol:
        raise TestFailure(f"Zr = {zr}, expected ~ {expected_z}")

    dut._log.info(f"Rotation test passed: Xr={xr}, Yr={yr}, Zr={zr}")


def run_tests():

    factory = TestFactor(test_CORDIC_UNIT)
    factory.generate_tests()

            
if __name__ == "__main__":

    run_tests()
