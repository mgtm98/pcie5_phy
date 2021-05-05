COMMON_ROOT_PATH			?= .																		# root of the files to be compiled
COMMON_INCLUDE_DIR  	:= $(strip $(COMMON_ROOT_PATH))/../..		# include directory for the `include 
COMMON_FILES					:=  																		# files to be compiled
COMPILE 							= $(strip $(COMMON_ROOT_PATH))/$(1) 		# used to append the root_path to the file_name

################################## Files to be compiled ##########################################
COMMON_FILES			 		+= $(call COMPILE,common_pkg.sv)
##################################################################################################

COMMON_BUILD: 
	@vlog +incdir+${UVM_HOME} +incdir+${COMMON_INCLUDE_DIR} ${COMMON_FILES}  -suppress 2275
	@echo Common package BUILD Done 
	@echo ------------------------------------------------------------------------------------------

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg