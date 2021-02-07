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
  pipe_seq_item seq_item ;

  begin
    seq_item = pipe_seq_item::type_id::create("seq_item");
    start_item(seq_item);
    if(!seq_item.randomize()) begin
      `uvm_error("body", "seq_item randomization failure")
    end
    finish_item(seq_item);
  end

endtask:body
