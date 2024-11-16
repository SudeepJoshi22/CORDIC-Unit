import os
import random
import sys
from pathlib import Path

import cocotb
from cocotb.triggers import Timer
from cocotb.regression import TestFactory

if cocotb.simulator.is_running():
    from cordic_unit_model import *

@cocotb.test
async def test_CORDIC_UNIT(dut):

    await directed_test(dut)

    coctb.log.info("Directed Test Passed!")

    await random_test(dut, N=10)

    cocotb.log.info("Random Test Passed!")

async def directed_test(dut):
    dut.angle.value = 

async def random_test(dut):


def run_tests():

        factory = TestFactor(test_CORDIC_UNIT)
        factory.generate_tests()

            
if __name__ == "__main__":

    run_tests()
