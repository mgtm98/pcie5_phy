class pipe_agent_config extends uvm_object;
  
  // UVM Factory Registration Macro
  `uvm_object_utils(pipe_agent_config)
  
  // BFM Virtual Interfaces
  virtual pipe_driver_bfm pipe_driver_bfm_h;
  virtual pipe_monitor_bfm pipe_monitor_bfm_h;
    
  //------------------------------------------
  // Data Members
  //------------------------------------------
  // Is the agent active or passive
  uvm_active_passive_enum active = UVM_ACTIVE;
  bit has_coverage_monitor = 1;
  event detected_tses;
  ts_t tses_received [NUM_OF_LANES];
  //event for starting polling state in linkup
  event power_down_detected;
  
  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "pipe_agent_config");
  
endclass
  
function pipe_agent_config::new(string name = "pipe_agent_config");
  super.new(name);
endfunction