class pipe_speed_change_seq extends pipe_base_seq;

`uvm_object_utils(pipe_speed_change_seq)

// Standard UVM Methods:
extern function new(string name = "pipe_speed_change_seq");
extern task body;
endclass:pipe_speed_change_seq

function pipe_speed_change_seq::new(string name = "pipe_speed_change_seq");
  super.new(name);
endfunction

task pipe_speed_change_seq::body;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  super.body;
  start_item(pipe_seq_item_h);
  if(!pipe_seq_item_h.randomize() with { pipe_operation == SPEED_CHANGE;} ) begin
    `uvm_error("body", "pipe_seq_item randomization failure")
  end
  `uvm_info(get_name(), "pipe_seq_item randomized", UVM_MEDIUM)
  finish_item(pipe_seq_item_h);
endtask:body
