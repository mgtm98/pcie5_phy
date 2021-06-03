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

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "pcie_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  //extern function void end_of_elaboration_phase (uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: pcie_test

function pcie_test::new(string name = "pcie_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pcie_test::build_phase(uvm_phase phase);
  // env configuration
  pcie_env_config pcie_env_config_h = pcie_env_config::type_id::create("pcie_env_config_h");

  // lpif & pipe configuration creation
  lpif_agent_config lpif_agent_config_h = lpif_agent_config::type_id::create("lpif_agent_config_h");
  pipe_agent_config pipe_agent_config_h = pipe_agent_config::type_id::create("pipe_agent_config_h");

  `uvm_info(get_name(), "Enter build_phase in pcie_teset", UVM_MEDIUM)
  //setting the lpif_agent conifgurations and needed handles
  if (!uvm_config_db #(lpif_driver_bfm_param) ::get(this, "", "lpif_driver_bfm", lpif_agent_config_h.lpif_driver_bfm_h))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface lpif_driver_bfm_h from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(lpif_monitor_bfm_param)::get(this, "", "lpif_monitor_bfm", lpif_agent_config_h.lpif_monitor_bfm_h))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface lpif_monitor_bfm_h from uvm_config_db. Have you set() it?")
  
  pcie_env_config_h.lpif_agent_config_h = lpif_agent_config_h;

  //setting the pipe_agent conifgurations and needed handles
  if (!uvm_config_db #(pipe_driver_bfm_param) ::get(this, "", "pipe_driver_bfm", pipe_agent_config_h.pipe_driver_bfm_h))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface pipe_driver_bfm_h from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(pipe_monitor_bfm_param)::get(this, "", "pipe_monitor_bfm", pipe_agent_config_h.pipe_monitor_bfm_h))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface pipe_monitor_bfm_h from uvm_config_db. Have you set() it?")
  
  pcie_env_config_h.pipe_agent_config_h = pipe_agent_config_h;

  // Add the LPIF & PIPE agent configuration objects so the sequences can access them
  uvm_config_db #(lpif_agent_config)::set(null, "lpif_seq", "lpif_agent_config_h", lpif_agent_config_h);
  uvm_config_db #(pipe_agent_config)::set(null, "pipe_seq", "pipe_agent_config_h", pipe_agent_config_h);
  // Add the ENV configuration object so the ENV can access it
  uvm_config_db #(pcie_env_config)::set(this, "pcie_env_h", "pcie_env_config_h", pcie_env_config_h);
  pcie_env_h = pcie_env::type_id::create("pcie_env_h", this);
  `uvm_info(get_name(), "Exit build_phase in pcie_teset", UVM_MEDIUM)
endfunction: build_phase

// function void pcie_test::end_of_elaboration_phase(uvm_phase phase);
//   `uvm_info(get_name(), "Enter end_of_elaboration_phase in pcie_teset", UVM_MEDIUM)
//   uvm_top.print_topology();
// endfunction : end_of_elaboration_phase

task pcie_test::run_phase(uvm_phase phase);
  // uvm_factory factory = uvm_coreservice_t::get().get_factory();
  // uvm_factory factory = uvm_factory::get();
  string arguments_value = "base_vseq"; //default value needs to be reviewed default value
  string used_vsequences[$];
  base_vseq vseq;
  uvm_object temp;

  uvm_cmdline_processor cmdline_proc = uvm_cmdline_processor::get_inst();
  `uvm_info(get_name(), "Enter run_phase in pcie_teset", UVM_MEDIUM)

  phase.raise_objection(this, "pcie_test");

  //get a string from the commandline arguments
  cmdline_proc.get_arg_value("+VSEQ=", arguments_value);
  uvm_split_string(arguments_value, ",", used_vsequences);

  foreach (used_vsequences[i]) 
  begin
    `uvm_info(get_name(), {"starting vseq:",used_vsequences[i]}, UVM_MEDIUM)

    temp = factory.create_object_by_name( used_vsequences[i], get_full_name(), used_vsequences[i]);
    $cast(vseq,temp);


    //assigning the secquencers handles
    vseq.lpif_sequencer_h = pcie_env_h.lpif_agent_h.lpif_sequencer_h;
    vseq.pipe_sequencer_h = pcie_env_h.pipe_agent_h.pipe_sequencer_h;
    vseq.start(null);
  end
  phase.drop_objection(this, "pcie_test");
  `uvm_info(get_name(), "Exit run_phase in pcie_teset", UVM_MEDIUM)    
endtask: run_phase