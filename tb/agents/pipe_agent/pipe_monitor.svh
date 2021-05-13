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
  extern function void notify_tses_received(ts_s tses [`NUM_OF_LANES]);
  // extern function void notify_tlp_sent(tlp_t tlp);
  // extern function void notify_tlp_received(tlp_t tlp);
  // extern function void notify_dllp_sent(dllp_t dllp);
  // extern function void notify_dllp_received(dllp_t dllp);
  // extern function void notify_enter_recovery_sent();
  // extern function void notify_enter_recovery_received();
  // extern function void notify_gen_change_sent(gen_t gen);
  // extern function void notify_gen_change_received(gen_t gen);
  extern function void notify_reset_detected();
  extern function void notify_receiver_detected();
  // extern function void notify_pclk_rate_change_sent(pclk_rate_t pclk_rate);
  // extern function void notify_pclk_rate_change_received(pclk_rate_t pclk_rate);
  extern function void pipe_polling_state_start();
  extern function void notify_idle_data_detected();
  extern function void early_start_polling();
  extern task  detect_posedge_clk();
  
endclass: pipe_monitor
   
function pipe_monitor::new(string name = "pipe_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction
  
function void pipe_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  ap_sent = new("ap_sent", this);
  ap_received = new("ap_received", this);
endfunction: build_phase
    

function void pipe_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  pipe_monitor_bfm_h = pipe_agent_config_h.pipe_monitor_bfm_h;
  pipe_monitor_bfm_h.proxy = this;
  -> pipe_monitor_bfm_h.build_connect_finished_e;
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


function void pipe_monitor::notify_tses_received(ts_s tses [`NUM_OF_LANES]);
  pipe_agent_config_h.tses_received = tses;
  -> pipe_agent_config_h.detected_tses_e;
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

// function void pipe_monitor::notify_tlp_sent(tlp_t tlp);
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = TLP_TRANSFER;
//   // Copying the data of the tlp to the sequence item
//   pipe_seq_item_h.tlp = tlp;
//   // Sending the sequence item to the analysis components
//   ap_sent.write(pipe_seq_item_h);
// endfunction

// function void pipe_monitor::notify_tlp_received(tlp_t tlp);
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = TLP_TRANSFER;
//   // Copying the data of the tlp to the sequence item
//   pipe_seq_item_h.tlp = tlp;
//   // Sending the sequence item to the analysis components
//   ap_received.write(pipe_seq_item_h);
// endfunction

// function void pipe_monitor::notify_dllp_sent(dllp_t dllp);
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = DLLP_TRANSFER;
//   // Copying the data of the tlp to the sequence item
//   pipe_seq_item_h.dllp = dllp;
//   // Sending the sequence item to the analysis components
//   ap_sent.write(pipe_seq_item_h);
// endfunction

// function void pipe_monitor::notify_dllp_received(dllp_t dllp);
//   // Creating the sequnce item
//   pipe_seq_item pipe_seq_item_h;
//   pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
//   // Determining the detected operation
//   pipe_seq_item_h.pipe_operation = DLLP_TRANSFER;
//   // Copying the data of the tlp to the sequence item
//   pipe_seq_item_h.dllp = dllp;
//   // Sending the sequence item to the analysis components
//   ap_received.write(pipe_seq_item_h);
// endfunction

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

function void pipe_monitor::pipe_polling_state_start();
  `uvm_info (get_type_name (), $sformatf ("pipe_polling_state_start is called"), UVM_MEDIUM)
  -> pipe_agent_config_h.start_polling_e;
 endfunction

 function void pipe_monitor::early_start_polling();
  `uvm_info (get_type_name (), $sformatf ("pipe_polling_state_start is called"), UVM_MEDIUM)
  -> pipe_agent_config_h.start_early_polling_e;
 endfunction

function void pipe_monitor::notify_idle_data_detected();
  `uvm_info (get_type_name (), $sformatf ("notify_idle_data_detected is called"), UVM_MEDIUM)
  -> pipe_agent_config_h.idle_data_detected_e;
endfunction