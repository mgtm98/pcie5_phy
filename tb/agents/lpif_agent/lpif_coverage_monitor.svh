`uvm_analysis_imp_decl(_sent)
`uvm_analysis_imp_decl(_received)

class lpif_coverage_monitor extends uvm_component;

  `uvm_component_utils(lpif_coverage_monitor)

  lpif_seq_item lpif_seq_item_h;

  uvm_analysis_imp_sent #(lpif_seq_item, lpif_coverage_monitor) analysis_export_sent;
  uvm_analysis_imp_received #(lpif_seq_item, lpif_coverage_monitor) analysis_export_received;

  covergroup lpif_seq_item_cov;
    
  endgroup: lpif_seq_item_cov

  function new(string name = "lpif_coverage_monitor", uvm_component parent = null);
    super.new(name, parent);
    lpif_seq_item_cov = new;
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_name(), "Enter lpif_coverage_monitor build_phase", UVM_MEDIUM)
    analysis_export_sent = new("analysis_export_sent", this);
    analysis_export_received = new("analysis_export_received", this);
  endfunction

  function void write_sent(lpif_seq_item lpif_seq_item_h);
    this.lpif_seq_item_h = lpif_seq_item_h;
    lpif_seq_item_cov.sample();
  endfunction

  function void write_received(lpif_seq_item lpif_seq_item_h);
    this.lpif_seq_item_h = lpif_seq_item_h;
    lpif_seq_item_cov.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    //write function
  endfunction: report_phase
endclass