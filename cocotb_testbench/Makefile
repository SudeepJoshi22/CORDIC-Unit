SIM ?= icarus

TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../rtl/CORDIC_UNIT.v

VERILOG_SOURCES += $(PWD)/../rtl/shift.v

VERILOG_SOURCES += $(PWD)/../rtl/add_sub.v

VERILOG_SOURCES += $(PWD)/../rtl/correction.v

cordic:
	$(MAKE) sim MODULE=test_CORDIC_UNIT TOPLEVEL=CORDIC_UNIT

include $(shell cocotb-config --makefiles)/Makefile.sim
