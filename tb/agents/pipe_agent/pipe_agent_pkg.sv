package pipe_agent_pkg;

  import uvm_pkg::*;
  import common_pkg::*;

  `include "uvm_macros.svh"
  `include "settings.svh"
  `include "pipe_types.svh"
  // `include "pipe_seq_item.svh"
  // `include "pipe_agent_config.svh"
  // `include "pipe_driver.svh"
  // `include "pipe_coverage_monitor.svh"
  // `include "pipe_monitor.svh"
  // typedef uvm_sequencer#(pipe_seq_item) pipe_sequencer;
  // `include "pipe_agent.svh"

  // // Typedef of parameterized PIPE interfaces
  // typedef pipe_if #(.pipe_num_of_lanes(`NUM_OF_LANES), .pipe_max_width(`PIPE_MAX_WIDTH)) pipe_if_param;
  // typedef pipe_driver_bfm #(.pipe_num_of_lanes(`NUM_OF_LANES), .pipe_max_width(`PIPE_MAX_WIDTH)) pipe_driver_bfm_param;
  // typedef pipe_monitor_bfm #(.pipe_num_of_lanes(`NUM_OF_LANES), .pipe_max_width(`PIPE_MAX_WIDTH)) pipe_monitor_bfm_param;

endpackage: pipe_agent_pkg
