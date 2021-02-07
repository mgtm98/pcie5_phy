class lpif_driver extends uvm_driver #(lpif_seq_item);

  `uvm_component_utils(lpif_driver)
  
  virtual lpif_driver_bfm lpif_driver_bfm_h;
  lpif_agent_config lpif_agent_config_h;

  function new(string name = "lpif_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    lpif_driver_bfm_h = lpif_agent_config_h.lpif_driver_bfm_h;
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask
endclass