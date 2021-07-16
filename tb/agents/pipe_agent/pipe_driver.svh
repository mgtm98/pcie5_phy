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
      SEND_EIOS:pipe_driver_bfm_h.send_eios();
      SEND_EIEOS:pipe_driver_bfm_h.send_eieos();
      SET_GEN:pipe_driver_bfm_h.current_gen=pipe_seq_item_h.gen;
      SEND_DATA: pipe_driver_bfm_h.send_data ();
      IDLE_DATA_TRANSFER: pipe_driver_bfm_h.send_idle_data();
      TLP_TRANSFER: pipe_driver_bfm_h.send_tlp(pipe_seq_item_h.tlp);
      DLLP_TRANSFER: pipe_driver_bfm_h.send_dllp(pipe_seq_item_h.dllp);
      // PCLK_RATE_CHANGE: pipe_driver_bfm_h.change_pclk_rate(pipe_seq_item_h.pclk_rate);
      // WIDTH_CHANGE: pipe_driver_bfm_h.change_width(pipe_seq_item_h.pipe_width);
      // SPEED_CHANGE: pipe_driver_bfm_h.change_speed();
      CHECK_EQ_PRESET_APPLIED: pipe_driver_bfm_h.eqialization_preset_applied();
      SET_EQ_PARAM:pipe_driver_bfm_h.set_eq_param(  pipe_seq_item_h.lf_usp,
                                                    pipe_seq_item_h.fs_usp,
                                                    pipe_seq_item_h.lf_dsp,
                                                    pipe_seq_item_h.fs_dsp,
                                                    pipe_seq_item_h.cursor,
                                                    pipe_seq_item_h.pre_cursor,
                                                    pipe_seq_item_h.post_cursor,
                                                    pipe_seq_item_h.tx_preset,
                                                    pipe_seq_item_h.rx_preset_hint,
                                                    pipe_seq_item_h.local_txPreset_coefficients);

      // SEND_IDLE_DATA: pipe_driver_bfm_h.send_idle_data(pipe_seq_item_h.start_lane, pipe_seq_item_h.end_lane);
      ASSERT_EVAL_FEEDBACK_CHANGED: begin
        assert(pipe_driver_bfm_h.eval_feedback_was_asserted == 1) else
        `uvm_error("", "Link eval feedback wasn't asserted")
      end
    endcase
    seq_item_port.item_done();
  end
  `uvm_info(get_name(), "Exit pipe_driver run_phase", UVM_MEDIUM)
endtask: run_phase
