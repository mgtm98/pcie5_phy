class pipe_link_up_seq extends pipe_base_seq;

  `uvm_object_utils(pipe_link_up_seq)

  ts_s ts_sent;
  ts_s tses_sent [NUM_OF_LANES];

  // Methods
  extern local task detect_state;
  extern local task polling_state;
  extern local task polling_active_state;
  extern local task polling_configuration_state;
  extern local task config_state;
  extern local task config_linkwidth_start_state_upstream;
  extern local task config_linkwidth_accept_state_upstream;
  extern local task config_lanenum_wait_state_upstream;
  extern local task config_lanenum_accept_state_upstream;
  extern local task config_complete_state_upstream;
  extern local task config_idle_state_upstream;
  extern local task config_linkwidth_start_state_downstream;
  extern local task config_linkwidth_accept_state_downstream;
  extern local task config_lanenum_wait_state_downstream;
  extern local task config_lanenum_accept_state_downstream;
  extern local task config_complete_state_downstream;
  extern local task config_idle_state_downstream;
  
  // Standard UVM Methods:
  extern function new(string name = "pipe_link_up_seq");
  extern task body;
  
endclass:pipe_link_up_seq

function pipe_link_up_seq::new(string name = "pipe_link_up_seq");
  super.new(name);
endfunction
  
task pipe_link_up_seq::body;
  super.body;
  detect_state;
  polling_state;
  config_state;
  -> pipe_agent_config_h.link_up_finished;
endtask: body

task pipe_link_up_seq::detect_state;
  wait(pipe_agent_config_h.reset_detected.triggered);
  `uvm_info("Reset detected");
  wait(pipe_agent_config_h.receiver_detected.triggered);
  `uvm_info("Receiver detected");
endtask

task pipe_link_up_seq::polling_state;

endtask

task pipe_link_up_seq::polling_active_state;

endtask

task pipe_link_up_seq::polling_configuration_state;

endtask

task pipe_link_up_seq::config_state;

endtask

task pipe_link_up_seq::config_linkwidth_start_state_upstream;

endtask

task pipe_link_up_seq::config_linkwidth_accept_state_upstream;

endtask

task pipe_link_up_seq::config_lanenum_wait_state_upstream;

endtask

task pipe_link_up_seq::config_lanenum_accept_state_upstream;

endtask

task pipe_link_up_seq::config_complete_state_upstream;

endtask

task pipe_link_up_seq::config_idle_state_upstream;

endtask

task pipe_link_up_seq::config_linkwidth_start_state_downstream;

endtask

task pipe_link_up_seq::config_linkwidth_accept_state_downstream;

endtask

task pipe_link_up_seq::config_lanenum_wait_state_downstream;

endtask

task pipe_link_up_seq::config_lanenum_accept_state_downstream;

endtask

task pipe_link_up_seq::config_complete_state_downstream;

endtask

task pipe_link_up_seq::config_idle_state_downstream;

endtask
