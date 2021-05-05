package lpif_agent_pkg;

  import uvm_pkg::*;
  import common_pkg::*;

  // `define UVM_REPORT_DISABLE_FILE_LINE  1
  `include "settings.svh"
  `include "uvm_macros.svh"
  `include "lpif_types.svh"
  `include "lpif_seq_item.svh"
  `include "lpif_agent_config.svh"
  `include "lpif_driver.svh"
  `include "lpif_coverage_monitor.svh"
  `include "lpif_monitor.svh"
  typedef uvm_sequencer#(lpif_seq_item) lpif_sequencer;
  `include "lpif_agent.svh"
 
endpackage: lpif_agent_pkg
