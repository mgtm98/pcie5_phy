class lpif_dummy_seq extends lpif_base_seq;
  
  `uvm_object_utils(lpif_dummy_seq)

  extern function new(string name = "lpif_dummy_seq");
  extern virtual task body();
  
endclass: lpif_dummy_seq

function lpif_dummy_seq::new(string name = "lpif_dummy_seq");
  super.new(name);
endfunction

task lpif_dummy_seq::body();
  lpif_seq_item lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
  `uvm_info(get_name(), "Started lpif_dummy_seq", UVM_NONE)
  start_item(lpif_seq_item_h);
  if(!lpif_seq_item_h.randomize() with {lpif_operation == lpif_agent_pkg::DLLP_TRANSFER;}) begin
    `uvm_fatal(get_name(), "Can't randomize lpif_seq_item")
  end
  finish_item(lpif_seq_item_h);
  start_item(lpif_seq_item_h);
  lpif_seq_item_h.lpif_operation = lpif_agent_pkg::SEND_DATA;
  finish_item(lpif_seq_item_h);
  #1;
  `uvm_info(get_name(), "Finished lpif_dummy_seq", UVM_NONE)
endtask