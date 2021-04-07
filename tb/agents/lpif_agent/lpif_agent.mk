LPIF_ROOT_PATH			?= .																# root of the files to be compiled
LPIF_INCLUDE_DIR  	:= $(strip $(LPIF_ROOT_PATH))/../..	# include directory for the `include 
LPIF_FILES					:=  																# files to be compiled
COMPILE 						= $(strip $(LPIF_ROOT_PATH))/$(1) 	# used to append the root_path to the file_name

################################## Files to be compiled ##########################################
LPIF_FILES					+= $(call COMPILE,lpif_agent_pkg.sv)
LPIF_FILES					+= $(call COMPILE,lpif_if.sv)
LPIF_FILES					+= $(call COMPILE,lpif_driver_bfm.sv)
LPIF_FILES					+= $(call COMPILE,lpif_monitor_bfm.sv)
#################################################################################################

LPIF_BUILD: 
	@vlog +incdir+${LPIF_INCLUDE_DIR} ${LPIF_FILES}  -suppress 2275 -suppress 2286
	@echo LPIF BUILD Done
	@echo ------------------------------------------------------------------------------------------

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg
