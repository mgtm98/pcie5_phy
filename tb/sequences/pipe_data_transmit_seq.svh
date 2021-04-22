class pipe_data_transmit_seq extends uvm_sequence #(pipe_seq_item);
  `uvm_object_utils(pipe_data_transmit_seq)

  extern function new(string name = "pipe_data_transmit_seq");
  extern virtual task body();
endclass //pipe_data_transmit_seq

function pipe_data_transmit_seq::new(string name = "pipe_data_transmit_seq");
  super.new(name);
endfunction

task pipe_data_transmit_seq::body();
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Wait for the sequencer to give grant
  start_item(pipe_seq_item_h);
  if (!pipe_seq_item_h.randomize() with {pipe_operation == TLP_TRANSFER || pipe_operation == DLLP_TRANSFER;})
  begin
    `uvm_fatal(get_name(), "Couldn't randomize the pipe_seq_item")
  end
  // Wait until the sequence item is used
  finish_item(pipe_seq_item_h);
endtask