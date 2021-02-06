class pcie_test extends uvm_test;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(pcie_test)

  //------------------------------------------
  // Data Members
  //------------------------------------------

  //------------------------------------------
  // Component Members
  //------------------------------------------
  // The environment class
  pcie_env pcie_env_h;

  // Configuration objects
  pcie_env_config pcie_env_config_h
  lpif_agent_config lpif_agent_config_h
  pipe_agent_config pipe_agent_config_h

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "pcie_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void run_phase(uvm_phase phase);

endclass: pcie_test

function spi_test_base::new(string name = "pcie_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void spi_test_base::build_phase(uvm_phase phase);
  virtual intr_bfm temp_intr_bfm;
  // env configuration
  pcie_env_config_h = pcie_env_config::type_id::create("pcie_env_config_h");

  // lpif & pipe configuration creation
  lpif_agent_config_h = lpif_agent_config::type_id::create("lpif_agent_config_h");
  pipe_agent_config_h = pipe_agent_config::type_id::create("pipe_agent_config_h");

  //setting the lpif_agent conifgurations and needed handles
  if (!uvm_config_db #(virtual lpif_monitor_bfm)::get(this, "", "lpif_monitor_bfm_h", lpif_agent_config_h.lpif_monitor_bfm_h))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface lpif_monitor_bfm_h from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual lpif_driver_bfm) ::get(this, "", "lpif_driver_bfm_h", lpif_agent_config_h.lpif_driver_bfm_h))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface lpif_driver_bfm_h from uvm_config_db. Have you set() it?")

  pcie_env_config_h.lpif_agent_config_h = lpif_agent_config_h;

  //setting the pipe_agent conifgurations and needed handles
  if (!uvm_config_db #(virtual pipe_monitor_bfm)::get(this, "", "pipe_monitor_bfm_h", pipe_agent_config_h.pipe_monitor_bfm_h))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface pipe_monitor_bfm_h from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual pipe_driver_bfm) ::get(this, "", "pipe_driver_bfm_h", pipe_agent_config_h.pipe_driver_bfm_h))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface pipe_driver_bfm_h from uvm_config_db. Have you set() it?")

  pcie_env_config_h.pipe_agent_config_h = pipe_agent_config_h;


  
  uvm_config_db #(pcie_env_config)::set(this, "*", "pcie_env_config", pcie_env_config_h);
  pcie_env_h = spi_env::type_id::create("pcie_env_h", this);
endfunction: build_phase