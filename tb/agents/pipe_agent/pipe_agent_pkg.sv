package pipe_agent_pkg;

  import uvm_pkg::*;

  `include "uvm_macros.svh"
  `include "pipe_if.sv"
  `include "pipe_monitor_bfm.sv"
  `include "pipe_driver_bfm.sv"
  `include "pipe_agent_config.svh"
  `include "pipe_seq_item.svh"
  typedef uvm_sequencer#(pipe_seq_item) pipe_sequencer;
  `include "pipe_driver.svh"
  `include "pipe_coverage_monitor.svh"
  `include "pipe_monitor.svh"
  `include "pipe_agent.svh"

endpackage: pipe_agent_pkg
