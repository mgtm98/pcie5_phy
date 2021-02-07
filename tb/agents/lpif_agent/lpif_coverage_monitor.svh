// TODO modify the structure for the 2 analysis ports
class lpif_coverage_monitor extends uvm_subscriber #(lpif_seq_item);

  `uvm_component_utils(lpif_coverage_monitor)

  lpif_seq_item lpif_seq_item_h;

  covergroup lpif_seq_item_cov;
    
  endgroup: lpif_seq_item_cov

  function new(string name = "lpif_coverage_monitor", uvm_component parent = null);
    super.new(name, parent);
    lpif_seq_item_cov = new;
  endfunction

  function void write(lpif_seq_item lpif_seq_item_h);

  endfunction
endclass