LPIF_INCLUDE_DIR  	?= ../..
LPIF_FILES 					?= lpif_agent_pkg.sv lpif_if.sv lpif_driver_bfm.sv lpif_monitor_bfm.sv

lpif_build: 
	vlog +incdir+${LPIF_INCLUDE_DIR} ${LPIF_FILES}  -suppress 2275 -suppress 2286

clean:
	rm -r work

# 2275 --> warning for file already included and will be overwritten 
# 2286 --> Using implicit +incdir+C:/questasim64_10.4e/uvm-1.1d/../verilog_src/uvm-1.1d/src 
#					 from import uvm_pkg