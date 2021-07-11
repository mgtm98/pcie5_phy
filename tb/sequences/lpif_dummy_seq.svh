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
  `uvm_info(get_name(), "lpif_seq_item started", UVM_NONE)
endtask