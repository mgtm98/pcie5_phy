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
  pipe_driver_bfm_h = pipe_agent_config_h.pipe_driver_bfm_h;
endfunction

task pipe_driver::run_phase(uvm_phase phase);
  pipe_seq_item seqitem;
  forever
   begin
     seq_item_port.get_next_item(seqitem);
     //call function in bfm to drive signals depeding on seq_item
     seq_item_port.item_done();
   end
endtask: run_phase
