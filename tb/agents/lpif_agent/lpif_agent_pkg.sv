package lpif_agent_pkg;

  import uvm_pkg::*;

  `include "uvm_macros.svh"
  `include "lpif_seq_item.svh"
  `include "lpif_agent_config.svh"
  `include "lpif_driver.svh"
  `include "lpif_coverage_monitor.svh"
  `include "lpif_monitor.svh"
  `include "lpif_agent.svh"
  typedef uvm_sequencer#(lpif_seq_item) lpif_sequencer;
 
endpackage: lpif_agent_pkg
