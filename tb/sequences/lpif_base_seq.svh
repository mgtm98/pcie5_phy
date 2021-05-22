class lpif_base_seq extends uvm_sequence #(lpif_seq_item);

  `uvm_object_utils(lpif_base_seq);

  lpif_agent_config lpif_agent_config_h;
  
  extern function new(string name = "lpif_base_seq");
  extern task pre_body();

endclass: lpif_base_seq

function lpif_base_seq::new(string name = "lpif_base_seq");
  super.new(name);
endfunction: new

task lpif_base_seq::pre_body();
  if(!uvm_config_db#(lpif_agent_config)::get(null, "lpif_seq", "lpif_agent_config_h", lpif_agent_config_h)) 
  begin
    `uvm_fatal(this.get_name(), "Cannot get LPIF Agent configuration from uvm_config_db");
  end
endtask