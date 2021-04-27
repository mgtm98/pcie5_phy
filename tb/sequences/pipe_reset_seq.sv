class pipe_reset_seq extends pipe_base_seq;

  `uvm_object_utils(pipe_reset_seq)

  // Standard UVM Methods:
  extern function new(string name = "pipe_link_up_seq");
  extern task body;
  
endclass:pipe_link_up_seq

function pipe_link_up_seq::new(string name = "pipe_link_up_seq");
  super.new(name);
endfunction
  
task pipe_link_up_seq::body;
  super.body;
  wait(pipe_agent_config_h.reset_detected_e.triggered);
  `uvm_info("Reset detected");
 
  -> pipe_agent_config_h.reset_finished_e;
endtask: body

endclass
