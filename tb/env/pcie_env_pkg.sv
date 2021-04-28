// Package Description:
//
package pcie_env_pkg;

  // Standard UVM import & include:
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Any further package imports:
  import lpif_agent_pkg::*;
  import pipe_agent_pkg::*;

  `uvm_analysis_imp_decl(_lpif_received)
  `uvm_analysis_imp_decl(_pipe_received)

  // Includes:
  `include "pcie_env_config.svh"
  `include "pcie_scoreboard.svh"
  `include "pcie_coverage_monitor.svh"
  `include "pcie_env.svh"

endpackage: pcie_env_pkg
