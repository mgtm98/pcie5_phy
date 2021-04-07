PIPE_ROOT_PATH			?= .																# root of the files to be compiled
PIPE_INCLUDE_DIR  	:= $(strip $(PIPE_ROOT_PATH))/../..	# include directory for the `include 
PIPE_FILES					:=  																# files to be compiled
COMPILE 						= $(strip $(PIPE_ROOT_PATH))/$(1) 	# used to append the root_path to the file_name

################################## Files to be compiled ##########################################
PIPE_FILES					+= $(call COMPILE,pipe_agent_pkg.sv)
PIPE_FILES					+= $(call COMPILE,pipe_if.sv)
PIPE_FILES					+= $(call COMPILE,pipe_driver_bfm.sv)
PIPE_FILES					+= $(call COMPILE,pipe_monitor_bfm.sv)
#################################################################################################

PIPE_BUILD: 
	@vlog +incdir+${PIPE_INCLUDE_DIR} ${PIPE_FILES}  -suppress 2275 -suppress 2286
	@echo PIPE BUILD Done 
	@echo ------------------------------------------------------------------------------------------

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg