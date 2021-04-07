TEST_ROOT_PATH			?= .																# root of the files to be compiled
TEST_INCLUDE_DIR  	:= $(strip $(TEST_ROOT_PATH))/../..	# include directory for the `include 
TEST_FILES					:=  																# files to be compiled
COMPILE 					  = $(strip $(TEST_ROOT_PATH))/$(1) 	# used to append the root_path to the file_name

################################## Files to be compiled ##########################################
TEST_FILES			 		+= $(call COMPILE,pcie_test_pkg.sv)
##################################################################################################

TEST_BUILD: 
	@vlog +incdir+${TEST_INCLUDE_DIR} ${TEST_FILES}  -suppress 2275 -suppress 2286
	@echo Test package BUILD Done 
	@echo ------------------------------------------------------------------------------------------

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg