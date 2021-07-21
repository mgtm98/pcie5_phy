class pipe_dummy_seq extends pipe_base_seq;
  
  `uvm_object_utils(pipe_dummy_seq)

  extern function new(string name = "pipe_dummy_seq");
  extern virtual task body();
  
endclass: pipe_dummy_seq

function pipe_dummy_seq::new(string name = "pipe_dummy_seq");
  super.new(name);
endfunction

task pipe_dummy_seq::body();
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  `uvm_info(get_name(), "Started pipe_dummy_seq", UVM_NONE)
  start_item(pipe_seq_item_h);
  if(!pipe_seq_item_h.randomize() with {pipe_operation == pipe_agent_pkg::IDLE_DATA_TRANSFER;}) begin
    `uvm_fatal(get_name(), "Can't randomize pipe_seq_item")
  end
  finish_item(pipe_seq_item_h);
  start_item(pipe_seq_item_h);
  pipe_seq_item_h.pipe_operation = pipe_agent_pkg::SEND_DATA;
  finish_item(pipe_seq_item_h);
  #1;
  `uvm_info(get_name(), "Finished pipe_dummy_seq", UVM_NONE)
endtask