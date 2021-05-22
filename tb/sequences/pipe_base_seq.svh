class pipe_base_seq extends uvm_sequence #(pipe_seq_item);

  `uvm_object_utils(pipe_base_seq);

   static ts_s tses [`NUM_OF_LANES];

  pipe_agent_config pipe_agent_config_h;

  extern function new(string name = "pipe_base_seq");
  extern task pre_body();
  
endclass: pipe_base_seq

function pipe_base_seq::new(string name = "pipe_base_seq");
  super.new(name);
endfunction: new

task pipe_base_seq::pre_body();
  if(!uvm_config_db#(pipe_agent_config)::get(null, "pipe_seq", "pipe_agent_config_h", pipe_agent_config_h)) 
  begin
    `uvm_fatal(get_name(), "Cannot get PIPE Agent configuration from uvm_config_db");
  end
endtask