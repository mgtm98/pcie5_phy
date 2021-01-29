class pipe_coverage_monitor extends uvm_subscriber #(pipe_seq_item);

`uvm_component_utils(apb_coverage_monitor);

pipe_seq_item pipe_seq_item_h;

covergroup pipe_seq_item_cov; 
	//write coverpoints
endgroup

extern function new(string name = "pipe_coverage_monitor", uvm_component parent = null);
extern function void report_phase(uvm_phase phase);
extern function void write(uvm_phase phase); 
endclass: pipe_coverage_monitor



function pipe_coverage_monitor::new(string name = "pipe_coverage_monitor", uvm_component parent = null);
  super.new(name, parent);
  pipe_seq_item_cov= new();
endfunction

function void pipe_coverage_monitor::report_phase(uvm_phase phase);
	//write function
endfunction: report_phase

function void pipe_coverage_monitor::write(pipe_seq_item seqitem);
  pipe_seq_item_h = seqitem; 
  pipe_seq_item_cov.sample();
endfunction

