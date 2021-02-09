class pipe_seq extends uvm_sequence #(pipe_seq_item);

`uvm_object_utils(pipe_seq)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------


//------------------------------------------
// Constraints
//------------------------------------------


//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "pipe_seq");
extern task body;
endclass:pipe_seq

function pipe_seq::new(string name = "spi_seq");
  super.new(name);
endfunction

task pipe_seq::body;
  pipe_seq_item pipe_seq_item_h ;
  begin
    seq_item = pipe_seq_item::type_id::create("pipe_seq_item_h");
    start_item(pipe_seq_item_h);
    if(!pipe_seq_item_h.randomize()) begin
      `uvm_error("body", "pipe_seq_item randomization failure")
    end
    `uvm_info(get_name(), "pipe_seq_item randomized", UVM_MEDIUM)
    finish_item(pipe_seq_item_h);
  end
endtask:body
