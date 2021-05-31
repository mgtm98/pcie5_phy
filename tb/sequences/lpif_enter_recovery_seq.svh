class lpif_enter_recovery_seq extends lpif_base_seq;
  
  `uvm_object_utils(lpif_enter_recovery_seq)

  extern function new(string name = "lpif_enter_recovery_seq");
  extern virtual task body();
endclass: lpif_enter_recovery_seq

function lpif_enter_recovery_seq::new(string name = "lpif_enter_recovery_seq");
  super.new(name);
endfunction

task lpif_enter_recovery_seq::body();
  lpif_seq_item lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
  // Wait for the sequencer to give grant
  start_item(lpif_seq_item_h);
  if (!lpif_seq_item_h.randomize() with {lpif_operation == ENTER_RETRAIN;})
  begin
    `uvm_fatal(get_name(), "Couldn't randomize the lpif_seq_item")
  end
  // Wait until the sequence item is used
  finish_item(lpif_seq_item_h);
endtask