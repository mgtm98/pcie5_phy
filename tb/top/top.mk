TOP_ROOT_PATH				?= $(strip .)									# root of the files to be compiled
TOP_INCLUDE_DIR  			:= $(strip $(TOP_ROOT_PATH)/..)					# include directory for the `include 
TOP_FILES					:=  											# files to be compiled
COMPILE 					= $(strip $(TOP_ROOT_PATH))/$(1) 				# used to append the root_path to the file_name
IS_ENV_UPSTREAM   			?= 1
PIPE_MAX_WIDTH ?= 32
NUM_OF_LANES ?= 16
LPIF_BUS_WIDTH ?= 512

################################## Files to be compiled ##########################################
TOP_FILES			 		+= $(call COMPILE,hdl_top.sv)
TOP_FILES			 		+= $(call COMPILE,hvl_top.sv)
RTL_FILES         			+= $(call COMPILE,../../rtl/*.v)
##################################################################################################

TOP_BUILD:
	@vlog ${RTL_FILES}
	@vlog +define+LPIF_BUS_WIDTH=${LPIF_BUS_WIDTH} +define+PIPE_MAX_WIDTH=${PIPE_MAX_WIDTH} +define+NUM_OF_LANES=${NUM_OF_LANES} +define+IS_ENV_UPSTREAM=${IS_ENV_UPSTREAM} +incdir+${TOP_INCLUDE_DIR} ${TOP_FILES}  -suppress 2275
	@echo Common package BUILD Done 
	@echo ------------------------------------------------------------------------------------------

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg