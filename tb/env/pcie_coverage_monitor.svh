class pcie_coverage_monitor extends uvm_component;

  `uvm_component_utils(pcie_coverage_monitor)

  lpif_seq_item lpif_seq_item_h;
  pipe_seq_item pipe_seq_item_h;
  uvm_analysis_export #(lpif_seq_item) lpif_export;
  uvm_analysis_export #(pipe_seq_item) pipe_export;
  uvm_tlm_analysis_fifo #(lpif_seq_item) lpif_fifo;
  uvm_tlm_analysis_fifo #(pipe_seq_item) pipe_fifo;

  covergroup pcie_coverage_monitor_cov;  
  endgroup : pcie_coverage_monitor_cov

  // Standard UVM Methods:
  extern function new(string name = "pcie_coverage_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

endclass: pcie_coverage_monitor

function pcie_coverage_monitor::new(string name = "pcie_coverage_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pcie_coverage_monitor::build_phase(uvm_phase phase);
  lpif_export = new("lpif_export", this);
  pipe_export = new("pipe_export", this);
  lpif_fifo = new("lpif_fifo", this);
  pipe_fifo = new("pipe_fifo", this);
endfunction:build_phase

function void pcie_coverage_monitor::connect_phase(uvm_phase phase);
  lpif_export.connect(lpif_fifo.analysis_export);
  pipe_export.connect(pipe_fifo.analysis_export);
endfunction:connect_phase

task pcie_coverage_monitor::run_phase(uvm_phase phase);
endtask:run_phase

function void pcie_coverage_monitor::report_phase(uvm_phase phase);
endfunction:report_phase
