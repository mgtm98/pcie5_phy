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
endfunction: build_phase


task pcie_test::run_phase(uvm_phase phase);
  string arguments_value = "base_vseq"; //default value needs to be reviewed default value
  string used_vsequences[$];
  base_vseq vseq;
  uvm_cmdline_processor cmdline_proc = uvm_cmdline_processor::get_inst();

  phase.raise_objection(this, "pcie_test");
  //get a string from the commandline arguments
  cmdline_proc.get_arg_value("+VSEQ=", arguments_value);
  uvm_split_string(arguments_value, ",", used_vsequences);

  
  foreach (used_vsequences[i]) 
  begin
      //checking which vseq should be used
    case(used_vsequences[i])
      // "link_up_vseq":         vseq = link_up_vseq::type_id::create("vseq");
      // "reset_vseq":           vseq = reset_vseq::type_id::create("vseq");
      // "data_exchange_vseq":   vseq = data_exchange_vseq::type_id::create("vseq");
      // "enter_recovery_vseq":  vseq = enter_recovery_vseq::type_id::create("vseq");
      // "speed_change_vseq":    vseq = speed_change_vseq::type_id::create("vseq");
      // "enter_l0s_vseq":       vseq = enter_l0s_vseq::type_id::create("vseq");
      // "exit_l0s_vseq":        vseq = exit_l0s_vseq::type_id::create("vseq");
      default:                `uvm_fatal(get_name(), "This virtual sequence doesn't exist")
    endcase

    //assigning the secquencers handles
    vseq.lpif_sequencer_h = pcie_env_h.lpif_agent_h.lpif_sequencer_h;
    vseq.pipe_sequencer_h = pcie_env_h.pipe_agent_h.pipe_sequencer_h;
    vseq.start(null);
  end

  phase.drop_objection(this, "pcie_test");
endtask: run_phase