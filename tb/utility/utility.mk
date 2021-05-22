UTILITY_ROOT_PATH		?= .										# root of the files to be compiled
UTILITY_INCLUDE_DIR  	:= $(strip $(UTILITY_ROOT_PATH))/.. 		# include directory for the `include 
UTILITY_FILES			:=  										# files to be compiled
COMPILE 				= $(strip $(UTILITY_ROOT_PATH))/$(1) 		# used to append the root_path to the file_name

################################## Files to be compiled ##########################################
UTILITY_FILES			 		+= $(call COMPILE,utility_pkg.sv)
##################################################################################################

UTILITY_BUILD: 
	@vlog +incdir+${UVM_HOME} +incdir+${UTILITY_INCLUDE_DIR} ${UTILITY_FILES}  -suppress 2275
	@echo Utility package BUILD Done 
	@echo ------------------------------------------------------------------------------------------

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg