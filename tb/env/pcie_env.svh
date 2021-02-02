class pcie_env extends uvm_env;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(pcie_env)
  //------------------------------------------
  // Data Members
  //------------------------------------------
  lpif_agent lpif_agent_h;
  pipe_agent pipe_agent_h;
  pcie_env_config pcie_env_config_h;
  pcie_scoreboard pcie_scoreboard_h;
  pcie_coverage_monitor pcie_coverage_monitor_h;

  // Standard UVM Methods:
  extern function new(string name = "pcie_env", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass:pcie_env

function pcie_env::new(string name = "pcie_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pcie_env::build_phase(uvm_phase phase);
  if (!uvm_config_db #(pcie_env_config)::get(this, "", "pcie_env_config_h", pcie_env_config_h))
    `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration pcie_env_config from uvm_config_db. Have you set() it?")

  uvm_config_db #(lpif_agent_config)::set(this, "lpif_agent_h*",
                                         "lpif_agent_config_h",
                                         pcie_env_config_h.lpif_agent_config_h);
  lpif_agent_h = lpif_agent::type_id::create("lpif_agent_h", this);

  uvm_config_db #(pipe_agent_config)::set(this, "pipe_agent_h*",
                                         "pipe_agent_config_h",
                                         pcie_env_config_h.pipe_agent_cfg_h);
  pipe_agent_h = pipe_agent::type_id::create("pipe_agent_h", this);

  if(pcie_env_config_h.has_pcie_scoreboard) begin
    pcie_scoreboard_h = pcie_scoreboard::type_id::create("pcie_scoreboard_h", this);
  end

  if(pcie_env_config_h.has_pcie_coverage_monitor) begin
    pcie_coverage_monitor_h = pcie_coverage_monitor::type_id::create("pcie_coverage_monitor_h", this);
  end
endfunction:build_phase

function void pcie_env::connect_phase(uvm_phase phase);
  if(pcie_env_config_h.has_pcie_scoreboard) begin
    lpif_agent_h.ap_sent.connect(pcie_scoreboard_h.lpif_export_sent);
    lpif_agent_h.ap_received.connect(pcie_scoreboard_h.lpif_export_received);
    pipe_agent_h.ap_sent.connect(pcie_scoreboard_h.pipe_export_sent);
    pipe_agent_h.ap_received.connect(pcie_scoreboard_h.pipe_export_received);
  end

  if(pcie_env_config_h.has_pcie_coverage_monitor) begin
    lpif_agent_h.ap_sent.connect(pcie_coverage_monitor_h.lpif_export_sent);
    lpif_agent_h.ap_received.connect(pcie_coverage_monitor_h.lpif_export_received);    
    pipe_agent_h.ap_sent.connect(pcie_coverage_monitor_h.pipe_export_sent);
    pipe_agent_h.ap_received.connect(pcie_coverage_monitor_h.pipe_export_received);
  end
endfunction: connect_phase
