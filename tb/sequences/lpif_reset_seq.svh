class lpif_reset_seq extends uvm_sequence #(lpif_seq_item);

    `uvm_object_utils(lpif_reset_seq)

    extern function new(string name = "lpif_reset_seq");
    extern task body;    

endclass: lpif_reset_seq

function lpif_reset_seq::new(string name = "lpif_reset_seq");
  super.new(name);
endfunction: new
  
task lpif_reset_seq::body;
  lpif_seq_item lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
  start_item(lpif_seq_item_h);
  if (!lpif_seq_item_h.randomize() with {lpif_operation == lpif_agent_pkg::RESET;}) begin
    `uvm_error(get_name(), "Can't randomize sequence item")
  end
  finish_item(lpif_seq_item_h);
endtask: body