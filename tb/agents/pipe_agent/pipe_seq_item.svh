
class pipe_seq_item extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(pipe_seq_item)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------

rand Pipe_operation_t pipe_operation
rand bit [7:0] tlp_data []     //??
rand bit [7:0] dllp_data []    //??
rand pipe_width_t pipe_width
rand pclk_rate_t pclk_rate


// Analysis members: ???


//------------------------------------------
// Constraints
//------------------------------------------


//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "pipe_seq_item");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);

endclass:pipe_seq_item

function pipe_seq_item::new(string name = "pipe_seq_item");
  super.new(name);
endfunction

function void pipe_seq_item::do_copy(uvm_object rhs);
  pipe_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
endfunction:do_copy

function bit pipe_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  pipe_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  // return super.do_compare(rhs, comparer) && .......
endfunction:do_compare
