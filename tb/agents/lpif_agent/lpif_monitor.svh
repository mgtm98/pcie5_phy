class lpif_monitor extends uvm_monitor;
  `uvm_component_utils(lpif_monitor);
  
  virtual lpif_monitor_bfm lpif_monitor_bfm_h;
  lpif_agent_config lpif_agent_config_h;    
  uvm_analysis_port #(lpif_seq_item) ap;
  
  //------------------------------------------
  // Methods
  //------------------------------------------
  
  // Standard UVM Methods:
  extern function new(string name = "lpif_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);

  //extern task run_phase(uvm_phase phase); 
  //not mentioned in the document!?

  
endclass: lpif_monitor

function lpif_monitor::new(string name = "lpif_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction
    
function void lpif_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);

  lpif_monitor_bfm_h = lpif_agent_config_h.lpif_monitor_bfm_h;  
  ap=new("ap",this);

  lpif_monitor_bfm_h.proxy = this;
  

endfunction: build_phase
