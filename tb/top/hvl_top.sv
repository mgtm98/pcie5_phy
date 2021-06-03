module hvl_top;
  
  import uvm_pkg::*;
  import utility_pkg::*;
  import pcie_test_pkg::*;
  
  reporter reporter_h;
  // color_formatter formater_h;
  initial begin
  	// reporter_h = new();
  	// formater_h = new();
  	// uvm_report_cb::add(null, formater_h);
    run_test();
  end
  
endmodule: hvl_top
  
  