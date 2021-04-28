class pcie_scoreboard extends uvm_component;

  `uvm_component_utils(pcie_scoreboard)

  uvm_analysis_export #(lpif_seq_item) lpif_export_sent;
  uvm_analysis_imp_lpif_received #(lpif_seq_item, pcie_scoreboard) lpif_export_received;
  uvm_analysis_export #(pipe_seq_item) pipe_export_sent;
  uvm_analysis_imp_pipe_received #(pipe_seq_item, pcie_scoreboard) pipe_export_received;
  uvm_tlm_analysis_fifo #(lpif_seq_item) lpif_fifo;
  uvm_tlm_analysis_fifo #(pipe_seq_item) pipe_fifo;


  // Standard UVM Methods:
  extern function new(string name = "pcie_scoreboard", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
  extern function void write_lpif_received(lpif_seq_item lpif_seq_item_h);
  extern function void write_pipe_received(pipe_seq_item pipe_seq_item_h);

endclass: pcie_scoreboard

function pcie_scoreboard::new(string name = "pcie_scoreboard", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pcie_scoreboard::build_phase(uvm_phase phase);
  lpif_export_sent = new("lpif_export_sent", this);
  lpif_export_received = new("lpif_export_received", this);
  pipe_export_sent = new("pipe_export_sent", this);  
  pipe_export_received = new("pipe_export_received", this);
  lpif_fifo = new("lpif_fifo", this);
  pipe_fifo = new("pipe_fifo", this);
endfunction:build_phase

function void pcie_scoreboard::connect_phase(uvm_phase phase);
  lpif_export_sent.connect(lpif_fifo.analysis_export);
  pipe_export_sent.connect(pipe_fifo.analysis_export);
endfunction:connect_phase

function void pcie_scoreboard::check_phase(uvm_phase phase);
endfunction:check_phase

function void pcie_scoreboard::write_lpif_received(lpif_seq_item lpif_seq_item_h);
endfunction:write_lpif_received

function void pcie_scoreboard::write_pipe_received(pipe_seq_item pipe_seq_item_h);
endfunction:write_pipe_received
