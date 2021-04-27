class lpif_reset_seq extends uvm_sequence #(lpif_seq_item);
    `uvm_object_utils(lpif_link_up_seq)
    extern function new(string name = "lpif_reset_seq");
    extern task body;    
endclass:lpif_link_up_seq

function lpif_link_up_seq::new(string name = "lpif_reset_seq");
  super.new(name);
endfunction
  
task lpif_link_up_seq::body;
  lpif_seq_item lpif_seq_item_h = lpif_seq_item::type_id::create("req");;
  start_item(lpif_seq_item_h);
  if (!lpif_seq_item_h.randomize() with {lpif_operation == RESET;}) begin
    `uvm_error(get_name(), "Can't randomize sequence item")
  end
  finish_item(lpif_seq_item_h);
endtask: body