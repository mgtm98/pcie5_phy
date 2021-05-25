class lpif_data_transmit_seq extends lpif_base_seq;

  `uvm_object_utils(lpif_data_transmit_seq)

  static const int unsigned MIN_NUM_OF_PACKETS = 10;
  static const int unsigned MAX_NUM_OF_PACKETS = 20;

  rand int num_of_packets;

  constraint num_of_packets_c {
  	num_of_packets >= lpif_data_transmit_seq::MIN_NUM_OF_PACKETS;
  	num_of_packets <= lpif_data_transmit_seq::MAX_NUM_OF_PACKETS;
  }

  extern function new(string name = "lpif_data_transmit_seq");
  extern virtual task body();

endclass //lpif_data_transmit_seq

function lpif_data_transmit_seq::new(string name = "lpif_data_transmit_seq");
  super.new(name);
endfunction

task lpif_data_transmit_seq::body();
  lpif_seq_item lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
  // Randomize num_of_packets
  if (!this.randomize()) begin
  	`uvm_fatal(get_name(), "Couldn't Randomize num_of_packets")
  end
  
  // Wait for the sequencer to give grant
	repeat(num_of_packets) begin
	  start_item(lpif_seq_item_h);
	  if (!lpif_seq_item_h.randomize() with {lpif_operation == lpif_agent_pkg::TLP_TRANSFER || lpif_operation == lpif_agent_pkg::DLLP_TRANSFER;})
	  begin
	    `uvm_fatal(get_name(), "Couldn't randomize the lpif_seq_item")
	  end
	  finish_item(lpif_seq_item_h);
	end
  start_item(lpif_seq_item_h);
  lpif_seq_item_h.lpif_operation = lpif_agent_pkg::SEND_DATA;
  finish_item(lpif_seq_item_h);
endtask