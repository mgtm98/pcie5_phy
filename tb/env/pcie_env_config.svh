class pcie_env_config extends uvm_object;

  // UVM Factory Registration Macro
  //
  `uvm_object_utils(pcie_env_config)

  //------------------------------------------
  // Data Members
  //------------------------------------------
  // Whether env analysis components are used:
  bit has_pcie_scoreboard = 1;
  bit has_pcie_coverage_monitor = 1;

  // Configurations for the sub_components
  lpif_agent_config lpif_agent_config_h;
  pipe_agent_config pipe_agent_config_h;

  //------------------------------------------
  // Methods
  //------------------------------------------
  // Standard UVM Methods:
  extern function new(string name = "pcie_env_config");

endclass: pcie_env_config

function pcie_env_config::new(string name = "pcie_env_config");
  super.new(name);
endfunction
