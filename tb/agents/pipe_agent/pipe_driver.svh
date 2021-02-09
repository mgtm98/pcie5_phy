class pipe_driver extends uvm_driver #(pipe_seq_item);

`uvm_component_utils(pipe_driver)

virtual pipe_driver_bfm pipe_driver_bfm_h;
pipe_agent_config pipe_agent_config_h;
  
extern function new(string name = "pipe_driver", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: pipe_driver


function pipe_driver::new(string name = "pipe_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pipe_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_name(), "Enter pipe_driver build_phase", UVM_MEDIUM)
  pipe_driver_bfm_h = pipe_agent_config_h.pipe_driver_bfm_h;
  `uvm_info(get_name(), "Exit pipe_driver build_phase", UVM_MEDIUM)
endfunction

task pipe_driver::run_phase(uvm_phase phase);
  pipe_seq_item pipe_seq_item_h;
  `uvm_info(get_name(), "Enter pipe_driver run_phase", UVM_MEDIUM)
  forever
   begin
     seq_item_port.get_next_item(pipe_seq_item_h);
     pipe_driver_bfm_h.drive(pipe_seq_item_h);
     seq_item_port.item_done();
     `uvm_info(get_name(), "Exit pipe_driver run_phase", UVM_MEDIUM)
  endtask
endtask: run_phase
