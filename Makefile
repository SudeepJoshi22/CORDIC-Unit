# Parent Makefile: generate Verilog and invoke Cocotb Makefile

# Q-format parameters and iteration count (override via CLI, e.g., make M=2 N=14 ITER=20)
M       ?= 1   # integer bits (excluding sign)
N       ?= 15  # fractional bits
ITER    ?= 15  # number of CORDIC iterations

# Export these variables to be read by the cocotb-testbench Python file
export N
export M
export ITER

SIM ?= icarus

TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/rtl/CORDIC_UNIT_GENERATED.v

PYTHONPATH := $(PYTHONPATH):$(PWD)/cocotb_testbench:$(PWD)/utils
export PYTHONPATH

# Enable waveform dump if WAVES is set
ifeq ($(WAVES), 1)
    COCOTB_WAVES ?= 1
endif

export COCOTB_WAVES

include $(shell cocotb-config --makefiles)/Makefile.sim

# Export environment variables for generation and testing
export M N ITER

# Phony targets
#targets that do not correspond to files
.PHONY: all generate cocotb clean

# Default: generate Verilog then run Cocotb tests
all: generate cocotb

# Generate the CORDIC unit Verilog with given parameters
generate:
	@echo "Generating CORDIC_UNIT.v with M=$(M), N=$(N), ITER=$(ITER)"
	@python scripts/cordic_gen.py --m $(M) --n $(N) -N $(ITER) -V

# Run Cocotb tests via the specified Makefile
test: generate
	@echo "Invoking Cocotb tests using '$(COCO_TARGET)'"
	
	@cd cocotb_testbench

	$(MAKE) sim MODULE=cocotb_testbench.test_CORDIC_UNIT TOPLEVEL=CORDIC_UNIT

