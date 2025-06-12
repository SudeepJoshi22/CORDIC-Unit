# Parent Makefile: generate Verilog and invoke Cocotb Makefile

# Q-format parameters and iteration count (override via CLI, e.g., make M=2 N=14 ITER=20)
M       ?= 1   # integer bits (excluding sign)
N       ?= 15  # fractional bits
ITER    ?= 15  # number of CORDIC iterations

# Path to the downstream Cocotb Makefile
COCO_TARGET ?= cocotb_testbench/Makefile.cocotb

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
cocotb: generate
	@echo "Invoking Cocotb tests using '$(COCO_TARGET)'"
	@$(MAKE) -f $(COCO_TARGET) cordic 

# Cleanup generated files
clean:
	@echo "Nothing to clean"
