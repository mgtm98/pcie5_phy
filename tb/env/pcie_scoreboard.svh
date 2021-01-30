class pcie_scoreboard extends uvm_component;

  `uvm_component_utils(pcie_scoreboard)

  uvm_analysis_export #(lpif_seq_item) lpif_export;
  uvm_analysis_export #(pipe_seq_item) pipe_export;
  uvm_tlm_analysis_fifo #(lpif_seq_item) lpif_fifo;
  uvm_tlm_analysis_fifo #(pipe_seq_item) pipe_fifo;

  // Standard UVM Methods:
  extern function new(string name = "pcie_scoreboard", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);

endclass: pcie_scoreboard

function pcie_scoreboard::new(string name = "pcie_scoreboard", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pcie_scoreboard::build_phase(uvm_phase phase);
  lpif_export = new("lpif_export", this);
  pipe_export = new("pipe_export", this);
  lpif_fifo = new("lpif_fifo", this);
  pipe_fifo = new("pipe_fifo", this);
endfunction:build_phase

function void pcie_scoreboard::connect_phase(uvm_phase phase);
  lpif_export.connect(lpif_fifo.analysis_export);
  pipe_export.connect(pipe_fifo.analysis_export);
endfunction:connect_phase

task pcie_scoreboard::run_phase(uvm_phase phase);
endtask:run_phase

function void pcie_scoreboard::check_phase(uvm_phase phase);
endfunction:check_phase
