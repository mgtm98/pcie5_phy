#################################### Pathes #####################################
PIPE_ROOT_PATH 		  	= ../agents/pipe_agent
LPIF_ROOT_PATH 		  	= ../agents/lpif_agent
ENV_ROOT_PATH       	= ../env
SEQ_ROOT_PATH       	= ../sequences
TEST_ROOT_PATH      	= ../test
COMMON_ROOT_PATH    	= ..
UTILITY_ROOT_PATH    	= ../utility
TOP_ROOT_PATH       	= ../top

################################ Build Configurations ################################
IS_ENV_UPSTREAM   		= 0
PIPE_MAX_WIDTH 		    = 32
NUM_OF_LANES 			= 16
LPIF_BUS_WIDTH 			= 512

###################################### Includes ######################################
include ../common.mk
include ../agents/pipe_agent/pipe_agent.mk
include ../agents/lpif_agent/lpif_agent.mk
include ../env/pcie_env.mk
include ../sequences/pcie_seq.mk
include ../test/pcie_test.mk
include ../top/top.mk
include ../utility/utility.mk

################################ Available Virutal Seqeunces ################################
# dummy_vseq
# reset_vseq
# link_up_vseq
# enter_recovery_vseq
# data_exchange_vseq

#################################### Run Configurations #####################################
TEST								= pcie_test
SEQ									= reset_vseq,link_up_vseq
# SEQ									= reset_vseq,dummy_vseq

#################################### Rules #####################################
build_pipe: 			COMMON_BUILD PIPE_BUILD_PACKAGE PIPE_BUILD_INTERFACES
build_lpif: 			COMMON_BUILD LPIF_BUILD_PACKAGE LPIF_BUILD_INTERFACES
build_agents: 			build_pipe build_lpif
build_seq:    			build_agents SEQ_BUILD
build_env:    			build_agents ENV_BUILD
build_test:    			build_agents build_env build_seq TEST_BUILD

build: COMMON_BUILD UTILITY_BUILD build_agents ENV_BUILD SEQ_BUILD TEST_BUILD TOP_BUILD
	@echo Project is built 

run:
	vsim -do "wave.do" hvl_top hdl_top +UVM_NO_RELNOTES +UVM_TESTNAME="$(TEST)" +VSEQ=${SEQ} -suppress 8887

clean:
	rm -r work