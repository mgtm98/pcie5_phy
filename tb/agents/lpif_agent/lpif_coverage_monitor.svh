class lpif_coverage_monitor extends uvm_component;

  `uvm_component_utils(lpif_coverage_monitor)

  lpif_seq_item lpif_seq_item_h;

  uvm_analysis_imp_sent #(lpif_seq_item, lpif_coverage_monitor) sent_export;
  uvm_analysis_imp_received #(lpif_seq_item, lpif_coverage_monitor) received_export;

  covergroup lpif_seq_item_cov;
    
  endgroup: lpif_seq_item_cov

  function new(string name = "lpif_coverage_monitor", uvm_component parent = null);
    super.new(name, parent);
    lpif_seq_item_cov = new;
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_name(), "Enter lpif_coverage_monitor build_phase", UVM_MEDIUM)
    sent_export = new("sent_export", this);
    received_export = new("received_export", this);
  endfunction

  function void write_sent(lpif_seq_item lpif_seq_item_h);
    this.lpif_seq_item_h = lpif_seq_item_h;
    lpif_seq_item_cov.sample();
  endfunction

  function void write_received(lpif_seq_item lpif_seq_item_h);
    this.lpif_seq_item_h = lpif_seq_item_h;
    lpif_seq_item_cov.sample();
  endfunction
endclass