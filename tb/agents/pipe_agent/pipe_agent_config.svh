class pipe_agent_config extends uvm_object;
  
  // UVM Factory Registration Macro
  `uvm_object_utils(pipe_agent_config)
  
  // BFM Virtual Interfaces
  pipe_driver_bfm_param pipe_driver_bfm_h;
  pipe_monitor_bfm_param pipe_monitor_bfm_h;
    
  uvm_active_passive_enum active = UVM_ACTIVE;
  bit has_coverage_monitor = 1;
  
  ts_s tses_received [];
  logic[1:0] new_width;
  logic[2:0] new_PCLKRate;
  logic[3:0] new_Rate;
  logic[17:0] new_TxDeemph;

  // Events
  event detected_tses_e;
  event detected_eieos_e;
  event detected_eieos_gen3_e;
  event detected_eios_e;
  event detected_eios_gen3_e;
  event detected_TxElecIdle_and_RxStandby_asserted_e;
  event detected_width_change_e;
  event detected_PCLKRate_change_e;
  event detected_Rate_change_e;
  event detected_TxDeemph_change_e;
  event reset_detected_e;
  event receiver_detected_e;
  event link_up_finished_e;
  event recovery_finished_e;
  event DUT_start_polling_e;
  event reset_finished_e;
  event idle_data_detected_e;
  event detected_posedge_clk_e;
  event detected_exit_electricle_idle_e;
  event power_down_change_e;
  extern function new(string name = "pipe_agent_config");
  
endclass
  
function pipe_agent_config::new(string name = "pipe_agent_config");
  super.new(name);
endfunction