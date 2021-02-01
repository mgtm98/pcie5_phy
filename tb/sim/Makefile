#
#------------------------------------------------------------------------------
#   Copyright 2018 Mentor Graphics Corporation
#   All Rights Reserved Worldwide
#
#   Licensed under the Apache License, Version 2.0 (the
#   "License"); you may not use this file except in
#   compliance with the License.  You may obtain a copy of
#   the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in
#   writing, software distributed under the License is
#   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied.  See
#   the License for the specific language governing
#   permissions and limitations under the License.
#------------------------------------------------------------------------------
RTL          ?= ../../../rtl
AGENTS       ?= ../agents
TAR_PATH     ?= ../../../../
TEST         ?= pipe_interrupt_test

all: work build run

tarball: clean tar

work:
	vlib work

build: work
	# vlog -incr +incdir+$(RTL)/pipe/rtl/verilog $(RTL)/pipe/rtl/verilog/*.v
	vlog -incr +incdir+$(AGENTS)/lpif_agent $(AGENTS)/lpif_agent/lpif_agent_pkg.sv -suppress 2263
	vlog -incr +incdir+$(AGENTS)/pipe_agent $(AGENTS)/pipe_agent/pipe_agent_pkg.sv -suppress 2263
	vlog -incr $(AGENTS)/lpif_agent/lpif_if.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/lpif_agent/lpif_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/lpif_agent/lpif_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/pipe_agent/pipe_if.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/pipe_agent/pipe_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/pipe_agent/pipe_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr +incdir+../env ../env/pcie_env_pkg.sv -suppress 2263
	# vlog -incr +incdir+../sequences ../sequences/pipe_bus_sequence_lib_pkg.sv -suppress 2263
	# vlog -incr +incdir+../sequences ../sequences/pipe_test_seq_lib_pkg.sv
	# vlog -incr +incdir+../test ../test/pipe_test_lib_pkg.sv -suppress 2263
	# vlog -incr -timescale 1ns/10ps +incdir+$(RTL)/pipe/rtl/verilog ../tb/hvl_top.sv
	# vlog -incr -timescale 1ns/10ps +incdir+$(RTL)/pipe/rtl/verilog ../tb/hdl_top.sv

debug:
	vopt -debug -designfile design.bin hvl_top hdl_top -o opt
	vsim -c -do "run -all" opt -qwavedb=signal
	visualizer -designfile design.bin -wavefile qwave.db

run:
	vsim -c -do "run -all" hvl_top hdl_top +UVM_TESTNAME="$(TEST)" -suppress 8887

clean:
	@rm -rf work transcript *~ vsim.wlf *.log *.tgz
	@find ../../../ -name "*~" -delete

tar:
	@(cd $(TAR_PATH);\
	tar -zcf pcie5_phy/tb/sim/pcie5_phy.tgz \
	pcie5_phy/tb/agents/lpif_agent \
	pcie5_phy/tb/agents/pipe_agent \
	pcie5_phy/rtl \
	pcie5_phy/tb/env \
	pcie5_phy/tb/test \
	pcie5_phy/tb/sequences \
	pcie5_phy/tb/top \
	pcie5_phy/tb/sim/Makefile)
