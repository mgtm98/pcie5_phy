class pipe_agent_config extends uvm_object;
  
  // UVM Factory Registration Macro
  `uvm_object_utils(pipe_agent_config)
  
  // BFM Virtual Interfaces
  virtual pipe_driver_bfm pipe_driver_bfm_h;
  virtual pipe_monitor_bfm pipe_monitor_bfm_h;
    
  uvm_active_passive_enum active = UVM_ACTIVE;
  bit has_coverage_monitor = 1;
  
  ts_s tses_received [NUM_OF_LANES];

  // Events
  event detected_tses_e;
  event reset_detected_e;
  event receiver_detected_e;
  event link_up_finished_e;
  event recovery_finished_e;
  event power_down_detected_e;
  event start_polling_e;
  
  extern function new(string name = "pipe_agent_config");
  
endclass
  
function pipe_agent_config::new(string name = "pipe_agent_config");
  super.new(name);
endfunction