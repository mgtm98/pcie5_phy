class pipe_driver extends uvm_driver #(pipe_seq_item);

`uvm_component_utils(pipe_driver)

pipe_driver_bfm_param pipe_driver_bfm_h;
pipe_agent_config pipe_agent_config_h;
  
extern function new(string name = "pipe_driver", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: pipe_driver


function pipe_driver::new(string name = "pipe_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pipe_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_name(), "Enter pipe_driver build_phase", UVM_MEDIUM)
  `uvm_info(get_name(), "Exit pipe_driver build_phase", UVM_MEDIUM)
endfunction

function void pipe_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_name(), "Enter pipe_driver connect_phase", UVM_MEDIUM)
  pipe_driver_bfm_h = pipe_agent_config_h.pipe_driver_bfm_h;
  `uvm_info(get_name(), "Exit pipe_driver connect_phase", UVM_MEDIUM)
endfunction

task pipe_driver::run_phase(uvm_phase phase);
  pipe_seq_item pipe_seq_item_h;
  `uvm_info(get_name(), "Enter pipe_driver run_phase", UVM_MEDIUM)
  forever
  begin
    seq_item_port.get_next_item(pipe_seq_item_h);
    case(pipe_seq_item_h.pipe_operation)
      SEND_TS: pipe_driver_bfm_h.send_ts(pipe_seq_item_h.ts_sent);
      SEND_TSES: pipe_driver_bfm_h.send_tses(pipe_seq_item_h.tses_sent);
      // SEND_IDLE_DATA: pipe_driver_bfm_h.send_idle_data();
      SEND_DATA: pipe_driver_bfm_h.send_data ();
      IDLE_DATA_TRANSFER: pipe_driver_bfm_h.send_idle_data();
      TLP_TRANSFER: pipe_driver_bfm_h.send_tlp(pipe_seq_item_h.tlp);
      DLLP_TRANSFER: pipe_driver_bfm_h.send_dllp(pipe_seq_item_h.dllp);
      // PCLK_RATE_CHANGE: pipe_driver_bfm_h.change_pclk_rate(pipe_seq_item_h.pclk_rate);
      // WIDTH_CHANGE: pipe_driver_bfm_h.change_width(pipe_seq_item_h.pipe_width);
      SPEED_CHANGE: pipe_driver_bfm_h.change_speed();
    endcase
    seq_item_port.item_done();
  end
  `uvm_info(get_name(), "Exit pipe_driver run_phase", UVM_MEDIUM)
endtask: run_phase
