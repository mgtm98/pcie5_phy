PIPE_ROOT_PATH 		  	= ../agents/pipe_agent
LPIF_ROOT_PATH 		  	= ../agents/lpif_agent
ENV_ROOT_PATH       	= ../env
SEQ_ROOT_PATH       	= ../sequences
TEST_ROOT_PATH      	= ../test
COMMON_ROOT_PATH    	= ..
TOP_ROOT_PATH       	= ../top
UVM_HOME				= C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 

include ../common.mk
include ../agents/pipe_agent/pipe_agent.mk
include ../agents/lpif_agent/lpif_agent.mk
include ../env/pcie_env.mk
include ../sequences/pcie_seq.mk
include ../test/pcie_test.mk
include ../top/top.mk

TEST								?= pcie_test
SEQ									?= reset_vseq,link_up_vseq

build_pipe: 				COMMON_BUILD PIPE_BUILD_PACKAGE PIPE_BUILD_INTERFACES
build_lpif: 				COMMON_BUILD LPIF_BUILD_PACKAGE LPIF_BUILD_INTERFACES
build_agents: 			COMMON_BUILD build_pipe build_lpif
build_seq:    			build_agents SEQ_BUILD
build_env:    			build_agents ENV_BUILD
build_test:    			build_agents build_env build_seq TEST_BUILD

build: COMMON_BUILD build_agents ENV_BUILD SEQ_BUILD TEST_BUILD TOP_BUILD
	@echo Project is built 

run:
	@vsim -c -do "run -all" hvl_top hdl_top +UVM_TESTNAME="$(TEST)" +VSEQ=${SEQ} -suppress 8887

clean:
	rm -r work