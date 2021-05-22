class pipe_data_transmit_seq extends pipe_base_seq;
  `uvm_object_utils(pipe_data_transmit_seq)
  rand int num_of_packets;
  constraint num_of_packets_c {
  	num_of_packets >= 10;
  	num_of_packets <= 100;
  }
  extern function new(string name = "pipe_data_transmit_seq");
  extern virtual task body();
endclass //pipe_data_transmit_seq

function pipe_data_transmit_seq::new(string name = "pipe_data_transmit_seq");
  super.new(name);
endfunction

task pipe_data_transmit_seq::body();
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Randomize num_of_packets
  if (!this.randomize()) begin
  	`uvm_fatal(get_name(), "Couldn't Randomize num_of_packets")
  end
  
  // Wait for the sequencer to give grant
	repeat(num_of_packets) begin
	  start_item(pipe_seq_item_h);
	  if (!pipe_seq_item_h.randomize() with {pipe_operation == TLP_TRANSFER || pipe_operation == DLLP_TRANSFER;})
	  begin
	    `uvm_fatal(get_name(), "Couldn't randomize the pipe_seq_item")
	  end
	  // Wait until the sequence item is used
	  finish_item(pipe_seq_item_h);
	end
  start_item(pipe_seq_item_h);
  pipe_seq_item_h.pipe_operation = SEND_DATA;
  finish_item(pipe_seq_item_h);
endtask