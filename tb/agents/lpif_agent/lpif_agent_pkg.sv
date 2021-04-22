`include "common_pkg.sv"

package lpif_agent_pkg;

  import uvm_pkg::*;
  import common_pkg::*;

  `include "uvm_macros.svh"
  `include "settings.svh"

  `uvm_analysis_imp_decl(_sent)
  `uvm_analysis_imp_decl(_received)
  `include "lpif_types.svh"
  
  // `include "lpif_seq_item.svh"
  // `include "lpif_agent_config.svh"
  // `include "lpif_driver.svh"
  // `include "lpif_coverage_monitor.svh"
  // `include "lpif_monitor.svh"
  // typedef uvm_sequencer#(lpif_seq_item) lpif_sequencer;
  // `include "lpif_agent.svh"
 
endpackage: lpif_agent_pkg
