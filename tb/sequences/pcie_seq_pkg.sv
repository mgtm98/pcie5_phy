package pcie_seq_pkg;
  `include "uvm_macros.svh"
  `include "settings.svh"

  import uvm_pkg::*;
  import common_pkg::*;
  import lpif_agent_pkg::*;
  import pipe_agent_pkg::*;

  // helpers macros
  `include "helper_macros.svh"

  // LPIF Sequences
  `include "lpif_base_seq.svh"
  `include "lpif_reset_seq.svh"
  `include "lpif_enter_recovery_seq.svh"
  `include "lpif_link_up_seq.svh"
  `include "lpif_data_transmit_seq.svh"

  // PIPE Sequences
  `include "pipe_base_seq.svh"
  `include "pipe_reset_seq.svh"
  `include "pipe_link_up_seq.svh"
  // `include "pipe_speed_change_seq.svh"
  // `include "pipe_speed_change_with_equalization_seq.svh"
  // `include "pipe_speed_change_without_equalization_seq.svh"
  `include "pipe_enter_recovery_seq.svh"
  `include "pipe_data_transmit_seq.svh"

  // Virtual Sequences
  `include "base_vseq.svh"
  `include "reset_vseq.svh"
  `include "link_up_vseq.svh"
  `include "enter_recovery_vseq.svh"
  `include "data_exchange_vseq.svh"

endpackage
