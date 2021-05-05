ENV_ROOT_PATH			?= .																# root of the files to be compiled
ENV_INCLUDE_DIR  	:= $(strip $(ENV_ROOT_PATH))/../..	# include directory for the `include 
ENV_FILES					:=  																# files to be compiled
COMPILE 					= $(strip $(ENV_ROOT_PATH))/$(1) 		# used to append the root_path to the file_name

################################## Files to be compiled ##########################################
ENV_FILES			 		+= $(call COMPILE,pcie_env_pkg.sv)
##################################################################################################

ENV_BUILD: 
	@vlog +incdir+${UVM_HOME} +incdir+${ENV_INCLUDE_DIR} ${ENV_FILES}  -suppress 2275
	@echo ENV BUILD Done 
	@echo ------------------------------------------------------------------------------------------

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg