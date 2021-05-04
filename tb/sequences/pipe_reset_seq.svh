class pipe_reset_seq extends pipe_base_seq;

  `uvm_object_utils(pipe_reset_seq)

  // Standard UVM Methods:
  extern function new(string name = "pipe_reset_seq");
  extern task body;
  
endclass:pipe_reset_seq

function pipe_reset_seq::new(string name = "pipe_reset_seq");
  super.new(name);
endfunction
  
task pipe_reset_seq::body;
  super.body;
  wait(pipe_agent_config_h.reset_detected_e.triggered);
  `uvm_info(get_name(), "Reset detected", UVM_MEDIUM);
 
  -> pipe_agent_config_h.reset_finished_e;
endtask: body
