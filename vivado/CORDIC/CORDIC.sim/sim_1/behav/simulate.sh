#!/bin/sh -f
xv_path="/opt/Xilinx/Vivado/2014.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim test_cordic_unit_behav -key {Behavioral:sim_1:Functional:test_cordic_unit} -tclbatch test_cordic_unit.tcl -log simulate.log
