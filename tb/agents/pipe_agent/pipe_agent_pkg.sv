package pipe_agent_pkg;

  import uvm_pkg::*;

  typedef enum {
    BUS_WIDTH_8  = 8,
    BUS_WIDTH_16 = 16,
    BUS_WIDTH_32 = 32
  } pipe_data_width_t;

  typedef struct {
    bit nothing1;
  } tlp_s;

  typedef struct {
    bit nothing2;
  } dllp_s;

  typedef enum {
    s1
  } state_e;

  typedef enum {
    s2
  } speed_mode_e;

  `include "uvm_macros.svh"
  `include "pipe_agent_config.svh"
  `include "pipe_seq_item.svh"
  typedef uvm_sequencer#(pipe_seq_item) pipe_sequencer;
  `include "pipe_driver.svh"
  `include "pipe_coverage_monitor.svh"
  `include "pipe_monitor.svh"
  `include "pipe_agent.svh"

endpackage: pipe_agent_pkg
