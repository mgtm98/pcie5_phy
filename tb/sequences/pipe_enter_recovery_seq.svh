class pipe_enter_recovery_seq extends pipe_base_seq;
  
  `uvm_object_utils(pipe_enter_recovery_seq)

  extern function new(string name = "pipe_enter_recovery_seq");
  extern virtual task body();
endclass: pipe_enter_recovery_seq

function pipe_enter_recovery_seq::new(string name = "pipe_enter_recovery_seq");
  super.new(name);
endfunction

task pipe_enter_recovery_seq::body();
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  super.body;
  
endtask