class pipe_monitor extends uvm_monitor;
  // UVM Factory Registration Macro
  `uvm_component_utils(pipe_monitor)
    
  // Virtual Interface
  pipe_monitor_bfm_param pipe_monitor_bfm_h;
    
  //------------------------------------------
  // Data Members
  //------------------------------------------
  pipe_agent_config pipe_agent_config_h;
  
  //------------------------------------------
  // Component Members
  //------------------------------------------
  uvm_analysis_port #(pipe_seq_item) ap_sent;
  uvm_analysis_port #(pipe_seq_item) ap_received;

  
  //------------------------------------------
  // Methods
  //------------------------------------------
  
  // Standard UVM Methods:
  extern function new(string name = "pipe_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

  // Proxy Methods:
  // extern function void notify_link_up_sent();
  // extern function void notify_link_up_received();
  extern task          detect_link_up();
  extern function void notify_tses_received(ts_s tses []);
  extern function void notify_eieos_received();
  extern function void notify_eieos_gen3_received();
  extern function void notify_eios_received();
  extern function void notify_eios_gen3_received();
  extern function void notify_TxElecIdle_and_RxStandby_asserted();
  extern function void notify_width_changed(logic[1:0] new_width);
  extern function void notify_PCLKRate_changed(logic[2:0] new_PCLKRate);
  extern function void notify_Rate_changed(logic[3:0] new_Rate);
  extern function void notify_tlp_sent(tlp_t tlp);
  extern function void notify_tlp_received(tlp_t tlp);
  extern function void notify_dllp_sent(dllp_t dllp);
  extern function void notify_dllp_received(dllp_t dllp);
  extern function void notify_idle_data_sent();
  extern function void notify_idle_data_received();
  // extern function void notify_enter_recovery_sent();
  // extern function void notify_enter_recovery_received();
  // extern function void notify_gen_change_sent(gen_t gen);
  // extern function void notify_gen_change_received(gen_t gen);
  extern function void notify_reset_detected();
  extern function void notify_receiver_detected();
  extern task  exit_electricle_idle();
  // extern function void notify_pclk_rate_change_sent(pclk_rate_t pclk_rate);
  // extern function void notify_pclk_rate_change_received(pclk_rate_t pclk_rate);
  extern function void DUT_polling_state_start();
  extern task  detect_posedge_clk();
  extern task  power_down_change();
  
endclass: pipe_monitor
   
function pipe_monitor::new(string name = "pipe_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction
  
function void pipe_monitor::build_phase(uvm_phase phase);
  `uvm_info(get_name(), "Enter pipe_monitor build_phase", UVM_MEDIUM)
  super.build_phase(phase);
  ap_sent = new("ap_sent", this);
  ap_received = new("ap_received", this);
  `uvm_info(get_name(), "Exit pipe_monitor build_phase", UVM_MEDIUM)
endfunction: build_phase
    

function void pipe_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_name(), "Enter pipe_monitor connect_phase", UVM_MEDIUM)
  pipe_monitor_bfm_h = pipe_agent_config_h.pipe_monitor_bfm_h;
  pipe_monitor_bfm_h.proxy = this;
  -> pipe_monitor_bfm_h.build_connect_finished_e;
  `uvm_info(get_name(), "Exit pipe_monitor connect_phase", UVM_MEDIUM)
endfunction: connect_phase

task pipe_monitor::detect_posedge_clk();
  -> pipe_agent_config_h.detected_posedge_clk_e;
endtask

task pipe_monitor::detect_link_up();
  pipe_seq_item pipe_seq_item_h;
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Wait till the sequence finishes the link up
  @(pipe_agent_config_h.link_up_finished_e);
  // Determining the detected operation
  pipe_seq_item_h.pipe_operation = LINK_UP;
  // Sending the sequence item to the analysis components
  ap_received.write(pipe_seq_item_h);
endtask

task pipe_monitor:: exit_electricle_idle();
 //pipe_monitor_bfm_h.detected_exit_electricle_idle_e = pipe_agent_config_h.detected_exit_electricle_idle_e;
 //-> pipe_agent_config_h.detected_exit_electricle_idle_e;
  //-> pipe_monitor_bfm_h.detected_exit_electricle_idle_e;
endtask

task pipe_monitor:: power_down_change();
  //pipe_monitor_bfm_h.detected_power_down_change_e = pipe_agent_config_h.power_down_change_e;
 //-> pipe_agent_config_h.power_down_change_e;
  //-> pipe_monitor_bfm_h.detected_power_down_change_e;
  //`uvm_info("pipe_monitor_bfm", "Powerdown= P0 detected in monitor ", UVM_LOW)
endtask

function void pipe_monitor::notify_tses_received(ts_s tses []);
  pipe_agent_config_h.tses_received = tses;
  -> pipe_agent_config_h.detected_tses_e;
endfunction
function void pipe_monitor::notify_eieos_received();
  -> pipe_agent_config_h.detected_eieos_e;
endfunction
function void pipe_monitor::notify_eieos_gen3_received();
  -> pipe_agent_config_h.detected_eieos_gen3_e;
endfunction
function void pipe_monitor::notify_eios_received();
  -> pipe_agent_config_h.detected_eios_e;
endfunction
function void pipe_monitor::notify_eios_gen3_received();
  -> pipe_agent_config_h.detected_eios_gen3_e;
endfunction
function void pipe_monitor::notify_TxElecIdle_and_RxStandby_asserted();
  -> pipe_agent_config_h.detected_TxElecIdle_and_RxStandby_asserted_e;
endfunction

function void pipe_monitor::notify_width_changed(logic[1:0] new_width);
  pipe_agent_config_h.new_width = new_width;
  -> pipe_agent_config_h.detected_width_change_e;
endfunction 

function void pipe_monitor::notify_PCLKRate_changed(logic[2:0] new_PCLKRate);
  //$display("flag",new_PCLKRate);
  pipe_agent_config_h.new_PCLKRate=new_PCLKRate;
  -> pipe_agent_config_h.detected_PCLKRate_change_e;
endfunction 
function void pipe_monitor::notify_Rate_changed(logic[3:0] new_Rate);
  //$display("flag",new_PCLKRate);
  pipe_agent_config_h.new_Rate=new_Rate;
  -> pipe_agent_config_h.detected_Rate_change_e;
endfunction 

// function void pipe_monitor::notify_link_up_sent();
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = LINK_UP;
//   // Sending the sequence item to the analysis components
//   ap_sent.write(pipe_seq_item_h);
// endfunction

// function void pipe_monitor::notify_link_up_received();
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = LINK_UP;
//   // Sending the sequence item to the analysis components
//   ap_received.write(pipe_seq_item_h);
// endfunction

function void pipe_monitor::notify_tlp_sent(tlp_t tlp);
  // Creating the sequnce item
  pipe_seq_item pipe_seq_item_h;
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Determining the detected operation
  pipe_seq_item_h.pipe_operation = TLP_TRANSFER;
  // Copying the data of the tlp to the sequence item
  pipe_seq_item_h.tlp = tlp;
  // Sending the sequence item to the analysis components
  ap_sent.write(pipe_seq_item_h);
endfunction

function void pipe_monitor::notify_tlp_received(tlp_t tlp);
  // Creating the sequnce item
  pipe_seq_item pipe_seq_item_h;
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Determining the detected operation
  pipe_seq_item_h.pipe_operation = TLP_TRANSFER;
  // Copying the data of the tlp to the sequence item
  pipe_seq_item_h.tlp = tlp;
  // Sending the sequence item to the analysis components
  ap_received.write(pipe_seq_item_h);
endfunction

function void pipe_monitor::notify_dllp_sent(dllp_t dllp);
  // Creating the sequnce item
  pipe_seq_item pipe_seq_item_h;
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Determining the detected operation
  pipe_seq_item_h.pipe_operation = DLLP_TRANSFER;
  // Copying the data of the tlp to the sequence item
  pipe_seq_item_h.dllp = dllp;
  // Sending the sequence item to the analysis components
  ap_sent.write(pipe_seq_item_h);
endfunction

function void pipe_monitor::notify_dllp_received(dllp_t dllp);
  // Creating the sequnce item
  pipe_seq_item pipe_seq_item_h;
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Determining the detected operation
  pipe_seq_item_h.pipe_operation = DLLP_TRANSFER;
  // Copying the data of the tlp to the sequence item
  pipe_seq_item_h.dllp = dllp;
  // Sending the sequence item to the analysis components
  ap_received.write(pipe_seq_item_h);
endfunction

// function void notify_enter_recovery_sent();
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = ENTER_RECOVERY;
//   // Sending the sequence item to the analysis components
//   ap_sent.write(pipe_seq_item_h);
// endfunction

// task notify_enter_recovery_received();
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Wait till the sequence finishes the link up
//   @(pipe_agent_config_h.recovery_finished_e);
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = ENTER_RECOVERY;
//   // Sending the sequence item to the analysis components
//   ap_received.write(pipe_seq_item_h);
// endfunction

// function void pipe_monitor::notify_gen_change_sent(gen_t gen);
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = SPEED_CHANGE;
//   // Copying the value of the generation to the sequence item
//   pipe_seq_item_h.gen = gen;
//   // Sending the sequence item to the analysis components
//   ap_sent.write(pipe_seq_item_h);
// endfunction

// function void pipe_monitor::notify_gen_change_received(gen_t gen);
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = SPEED_CHANGE;
//   // Copying the value of the generation to the sequence item
//   pipe_seq_item_h.gen = gen;
//   // Sending the sequence item to the analysis components
//   ap_received.write(pipe_seq_item_h);
// endfunction

function void pipe_monitor::notify_reset_detected();
  // Creating the sequnce item
  pipe_seq_item pipe_seq_item_h;
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Determining the detected operation
  pipe_seq_item_h.pipe_operation = RESET;
  // Sending the sequence item to the analysis components
  ap_received.write(pipe_seq_item_h);

  -> pipe_agent_config_h.reset_detected_e;
endfunction

function void pipe_monitor::notify_receiver_detected();
  -> pipe_agent_config_h.receiver_detected_e;
endfunction

// function void pipe_monitor::notify_pclk_rate_change_sent(pclk_rate_t  pclk_rate);
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = PCLK_RATE_CHANGE;
//   // Copying the value of the PCLK rate to the sequence item
//   pipe_seq_item_h.pclk_rate = pclk_rate;
//   // Sending the sequence item to the analysis components
//   ap_sent.write(pipe_seq_item_h);
// endfunction

// function void pipe_monitor::notify_pclk_rate_change_received(pclk_rate_t  pclk_rate);
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = PCLK_RATE_CHANGE;
//   // Copying the value of the PCLK rate to the sequence item
//   pipe_seq_item_h.pclk_rate = pclk_rate;
//   // Sending the sequence item to the analysis components
//   ap_received.write(pipe_seq_item_h);
// endfunction

function void pipe_monitor::DUT_polling_state_start();
  `uvm_info (get_type_name (), $sformatf ("DUT_polling_state_start is called"), UVM_MEDIUM)
  -> pipe_agent_config_h.DUT_start_polling_e;
 endfunction


function void pipe_monitor::notify_idle_data_received();
  // Creating the sequnce item
  pipe_seq_item pipe_seq_item_h;
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Determining the detected operation
  pipe_seq_item_h.pipe_operation = IDLE_DATA_TRANSFER;
  // Sending the sequence item to the analysis components
  ap_received.write(pipe_seq_item_h);

  `uvm_info (get_type_name (), $sformatf ("notify_idle_data_received is called"), UVM_MEDIUM)
  -> pipe_agent_config_h.idle_data_detected_e;
endfunction

function void pipe_monitor::notify_idle_data_sent();
  // Creating the sequnce item
  pipe_seq_item pipe_seq_item_h;
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  // Determining the detected operation
  pipe_seq_item_h.pipe_operation = IDLE_DATA_TRANSFER;
  // Sending the sequence item to the analysis components
  ap_received.write(pipe_seq_item_h);
endfunction