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
endtask