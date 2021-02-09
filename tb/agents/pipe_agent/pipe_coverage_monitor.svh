class pipe_coverage_monitor extends uvm_subscriber #(pipe_seq_item);

	`uvm_component_utils(pipe_coverage_monitor);

pipe_seq_item pipe_seq_item_h;

uvm_analysis_imp_sent #(pipe_seq_item, pipe_coverage_monitor) sent_export;
uvm_analysis_imp_received #(pipe_seq_item, pipe_coverage_monitor) received_export;


covergroup pipe_seq_item_cov; 
	//write coverpoints
endgroup

extern function new(string name = "pipe_coverage_monitor", uvm_component parent = null);
extern function void report_phase(uvm_phase phase);
extern function void build_phase(uvm_phase phase);

function void write_sent(pipe_seq_item pipe_seq_item_h);
  this.pipe_seq_item_h = pipe_seq_item_h;
  pipe_seq_item_cov.sample();
endfunction

function void write_received(pipe_seq_item pipe_seq_item_h);
  this.pipe_seq_item_h = pipe_seq_item_h;
  pipe_seq_item_cov.sample();
endfunction

endclass: pipe_coverage_monitor

function pipe_coverage_monitor::build_phase(uvm_phase phase);
  `uvm_info(get_name(), "Enter pipe_coverage_monitor build_phase", UVM_MEDIUM)
   sent_export = new("sent_export", this);
   received_export = new("received_export", this);
   `uvm_info(get_name(), "Exit pipe_coverage_monitor build_phase", UVM_MEDIUM)
endfunction  

function void pipe_coverage_monitor::new(string name = "pipe_coverage_monitor", uvm_component parent = null);
  super.new(name, parent);
  pipe_seq_item_cov= new();
endfunction

function void pipe_coverage_monitor::report_phase(uvm_phase phase);
	//write function
endfunction: report_phase
endfunction

