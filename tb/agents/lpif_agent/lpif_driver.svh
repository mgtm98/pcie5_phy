class lpif_driver extends uvm_driver #(lpif_seq_item);

  `uvm_component_utils(lpif_driver)
  
  virtual lpif_driver_bfm lpif_driver_bfm_h;
  lpif_agent_config lpif_agent_config_h;

  function new(string name = "lpif_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "Enter lpif_driver build_phase", UVM_MEDIUM)
    `uvm_info(get_name(), "Exit lpif_driver build_phase", UVM_MEDIUM)
  endfunction: build_phase
  

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_name(), "Enter lpif_driver connect_phase", UVM_MEDIUM)
    lpif_driver_bfm_h = lpif_agent_config_h.lpif_driver_bfm_h;
    `uvm_info(get_name(), "Exit lpif_driver connect_phase", UVM_MEDIUM)
  endfunction

  task run_phase(uvm_phase phase);
    lpif_seq_item lpif_seq_item_h;
    super.run_phase(phase);
    `uvm_info(get_name(), "Enter lpif_driver run_phase", UVM_MEDIUM)
    forever
    begin
      seq_item_port.get_next_item(lpif_seq_item_h);
      lpif_driver_bfm_h.lpif_driver_bfm_dummy();
      seq_item_port.item_done();
    end
    `uvm_info(get_name(), "Exit lpif_driver run_phase", UVM_MEDIUM)
  endtask
endclass