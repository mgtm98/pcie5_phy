class lpif_agent_config extends uvm_object;
  
  // UVM Factory Registration Macro
  `uvm_object_utils(lpif_agent_config)
  
  // BFM Virtual Interfaces
  virtual lpif_driver_bfm lpif_driver_bfm_h;
  virtual lpif_monitor_bfm lpif_monitor_bfm_h;
    
  //------------------------------------------
  // Data Members
  //------------------------------------------
  // Is the agent active or passive
  uvm_active_passive_enum active = UVM_ACTIVE;
  bit has_coverage_monitor = 1;
  
  //------------------------------------------
  // Methods
  //------------------------------------------
  function new(string name = "lpif_agent_config");
    super.new(name);
  endfunction
  
endclass



