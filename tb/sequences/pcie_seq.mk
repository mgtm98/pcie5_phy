SEQ_ROOT_PATH			?= .																# root of the files to be compiled
SEQ_INCLUDE_DIR  	:= $(strip $(SEQ_ROOT_PATH))/..			# include directory for the `include 
SEQ_FILES					:=  																# files to be compiled
COMPILE 					= $(strip $(SEQ_ROOT_PATH))/$(1) 		# used to append the root_path to the file_name
PIPE_MAX_WIDTH ?= 32
NUM_OF_LANES ?= 16
LPIF_BUS_WIDTH ?= 512

################################## Files to be compiled ##########################################
SEQ_FILES			 		+= $(call COMPILE,pcie_seq_pkg.sv)
##################################################################################################

SEQ_BUILD: 
	@vlog +define+LPIF_BUS_WIDTH=${LPIF_BUS_WIDTH} +define+PIPE_MAX_WIDTH=${PIPE_MAX_WIDTH} +define+NUM_OF_LANES=${NUM_OF_LANES} +incdir+${UVM_HOME} +incdir+${SEQ_INCLUDE_DIR} ${SEQ_FILES}  -suppress 2275
	@echo Sequence package BUILD Done 
	@echo ------------------------------------------------------------------------------------------

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg