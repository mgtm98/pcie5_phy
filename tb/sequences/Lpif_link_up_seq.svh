class lpif_link_up_seq extends lpif_base_seq;
  `uvm_object_utils(lpif_link_up_seq)

  // Methods
  
  // Standard UVM Methods:
  extern function new(string name = "lpif_link_up_seq");
  extern task body;    
  
endclass: lpif_link_up_seq

function lpif_link_up_seq::new(string name = "lpif_link_up_seq");
  super.new(name);
endfunction
  
task lpif_link_up_seq::body;
  lpif_seq_item lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
  `uvm_info("lpif_link_up_seq", "entered lpif_link_up_seq", UVM_LOW)
  start_item(lpif_seq_item_h);
  if (!lpif_seq_item_h.randomize() with {lpif_operation == lpif_agent_pkg::LINK_UP;})
  begin
    `uvm_error(get_name(), "Can't randomize sequence item")
  end
  finish_item(lpif_seq_item_h);
  `uvm_info("lpif_link_up_seq", "finished lpif_link_up_seq", UVM_LOW)
endtask: body