package pipe_agent_pkg;

  import uvm_pkg::*;
  import common_pkg::*;
  
  `include "settings.svh"
  `include "uvm_macros.svh"
  `include "pipe_types.svh"
  `include "pipe_seq_item.svh"
  `include "pipe_agent_config.svh"
  `include "pipe_driver.svh"
  `include "pipe_coverage_monitor.svh"
  `include "pipe_monitor.svh"
  typedef uvm_sequencer#(pipe_seq_item) pipe_sequencer;
  `include "pipe_agent.svh"
  `include "descrambler_scrambler.svh"

endpackage: pipe_agent_pkg
