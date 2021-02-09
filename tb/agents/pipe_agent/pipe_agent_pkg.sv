`include "common_pkg.sv"
`include "settings.svh"

package pipe_agent_pkg;

  import uvm_pkg::*;
  import common_pkg::*; 

  `include "uvm_macros.svh"
  `include "pipe_types.svh"
  `include "pipe_agent_config.svh"
  `include "pipe_seq_item.svh"
  typedef uvm_sequencer#(pipe_seq_item) pipe_sequencer;
  `include "pipe_driver.svh"
  `include "pipe_coverage_monitor.svh"
  `include "pipe_monitor.svh"
  `include "pipe_agent.svh"

endpackage: pipe_agent_pkg
