class lpif_monitor extends uvm_monitor;
  // UVM Factory Registration Macro
  `uvm_component_utils(lpif_monitor);
  // bfm handle
  virtual lpif_monitor_bfm lpif_monitor_bfm_h;
  // config object handle
  lpif_agent_config lpif_agent_config_h;    
  // two anlysis ports for TX and RX
  uvm_analysis_port #(lpif_seq_item) ap_sent;
  uvm_analysis_port #(lpif_seq_item) ap_received;
  
  //------------------------------------------
  //  notification Methods
  //------------------------------------------
  extern function void lpif_monitor_dummy();

  extern function void notify_link_up_sent();
  extern function void notify_link_up_received();
  extern function void notify_tlp_sent(tlp_t tlp);
  extern function void notify_dllp_sent(dllp_t dllp);
  extern function void notify_tlp_received(tlp_t tlp);
  extern function void notify_dllp_received(dllp_t dllp);
  extern function void notify_reset_received();
  extern function void notify_reset_sent();
  // extern function void notify_speed_mode_change_sent();
  // extern function void notify_speed_mode_change_received();
  extern function void notify_retrain_sent ();
  extern function void notify_retrain_received ();
  // extern function void notify_enter_l0s_sent ();
  // extern function void notify_enter_l0s_received ();
  // extern function void notify_exit_l0s_sent();
  // extern function void notify_exit_l0s_received();

    
    
  // Standard UVM Methods:
  extern function new(string name = "lpif_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  
endclass: lpif_monitor

//new  
function lpif_monitor::new(string name = "lpif_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

//build   
function void lpif_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info (get_type_name (), "building lpif monitor", UVM_MEDIUM)

  //analysis ports creation
  ap_sent = new("ap_sent",this);
  ap_received = new("ap_received",this);

  `uvm_info (get_type_name (), "lpif monitor built", UVM_MEDIUM)
endfunction

//connect   
function void lpif_monitor::connect_phase(uvm_phase phase);

  super.connect_phase(phase);
  `uvm_info (get_type_name (), "connecting lpif monitor", UVM_MEDIUM)
  //getting bfm handle from the agent config object
  lpif_monitor_bfm_h = lpif_agent_config_h.lpif_monitor_bfm_h;  

  //passing proxy of the monitor to the bfm
  lpif_monitor_bfm_h.proxy = this;
  `uvm_info (get_type_name (), "lpif monitor connected", UVM_MEDIUM)
endfunction

//dummy function used only for tesring our work----------------------------------------------------------------------------  
function void lpif_monitor::lpif_monitor_dummy();
  lpif_seq_item lpif_seq_item_h;
  `uvm_info (get_type_name (), $sformatf ("lpif_monitor_dummy is called"), UVM_MEDIUM)
  //creating sequnce item
  lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
  //determining the detected operation
  lpif_seq_item_h.lpif_operation = LINK_UP;
  //sending sequnce item to the anlysis components
  `uvm_info (get_type_name (), "lpif_monitor_dummy sent a link-up seq_item to anlysis components", UVM_MEDIUM)
  ap_sent.write(lpif_seq_item_h);
  ap_received.write(lpif_seq_item_h);
endfunction

function void lpif_monitor::notify_link_up_sent();
  //creating sequnce item
  lpif_seq_item lpif_seq_item_h;
  lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
  //determining the detected operation
  lpif_seq_item_h.lpif_operation=LINK_UP;
  //sending sequnce item to the anlysis components
  ap_sent.write(lpif_seq_item_h);
endfunction

function void lpif_monitor::notify_link_up_received();
  //creating sequnce item
  lpif_seq_item lpif_seq_item_h;
  lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
  //determining the detected operation
  lpif_seq_item_h.lpif_operation=LINK_UP;
  //sending sequnce item to the anlysis components
  ap_received.write(lpif_seq_item_h);
endfunction  

function void lpif_monitor::notify_tlp_sent(tlp_t tlp);
  //creating sequnce item
  lpif_seq_item lpif_seq_item_h;
  lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
  //determining the detected operation
  lpif_seq_item_h.lpif_operation=TLP_TRANSFER;
  // copying the content of the tlp inside the sequence item
  lpif_seq_item_h.tlp = new tlp;
  //sending sequnce item to the anlysis components
  ap_sent.write(lpif_seq_item_h);
endfunction

function void lpif_monitor::notify_tlp_received(tlp_t tlp);
  //creating sequnce item
  lpif_seq_item lpif_seq_item_h;
  lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
  //determining the detected operation
  lpif_seq_item_h.lpif_operation=TLP_TRANSFER;
  // copying the content of the tlp inside the sequence item
  lpif_seq_item_h.tlp = new tlp;
  //sending sequnce item to the anlysis components
  ap_received.write(lpif_seq_item_h);
endfunction

 function void lpif_monitor::notify_dllp_sent(dllp_t dllp);
   //creating sequnce item
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
   //determining the detected operation
   lpif_seq_item_h.lpif_operation=DLLP_TRANSFER;
   // copying the content of the dllp inside the sequence item
   lpif_seq_item_h.dllp = new dllp;
   //sending sequnce item to the anlysis components
   ap_sent.write(lpif_seq_item_h);
 endfunction

 function void lpif_monitor::notify_dllp_received(dllp_t dllp);
   //creating sequnce item
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
   //determining the detected operation
   lpif_seq_item_h.lpif_operation=DLLP_TRANSFER;
   // copying the content of the dllp inside the sequence item
   lpif_seq_item_h.dllp = new dllp;
   //sending sequnce item to the anlysis components
   ap_received.write(lpif_seq_item_h);
  endfunction

 function void lpif_monitor::notify_reset_received();
   //creating sequnce item
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
   //determining the detected operation
   lpif_seq_item_h.lpif_operation=RESET;
   //sending sequnce item to the anlysis components
   ap_received.write(lpif_seq_item_h);
  endfunction

 function void lpif_monitor::notify_reset_sent();
   //creating sequnce item
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
   //determining the detected operation
   lpif_seq_item_h.lpif_operation=RESET;
   //sending sequnce item to the anlysis components
   ap_sent.write(lpif_seq_item_h);
  endfunction

//  function void lpif_monitor::notify_speed_mode_change_sent();
//    //creating sequnce item
//    lpif_seq_item lpif_seq_item_h;
//    lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
//    //determining the detected operation
//    lpif_seq_item_h.lpif_operation=SPEED_CHANGE;
//    //sending sequnce item to the anlysis components
//    ap_sent.write(lpif_seq_item_h);
//   endfunction

//  function void lpif_monitor::notify_speed_mode_change_received();
//    //creating sequnce item
//    lpif_seq_item lpif_seq_item_h;
//    lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
//    //determining the detected operation
//    lpif_seq_item_h.lpif_operation=SPEED_CHANGE;
//    //sending sequnce item to the anlysis components
//    ap_received.write(lpif_seq_item_h);
//  endfunction

 function void lpif_monitor::notify_retrain_sent ();
   //creating sequnce item
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
   //determining the detected operation
   lpif_seq_item_h.lpif_operation=ENTER_RECOVERY;
   //sending sequnce item to the anlysis components
   ap_sent.write(lpif_seq_item_h);
  endfunction

 function void lpif_monitor::notify_retrain_received ();
   //creating sequnce item
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h");
   //determining the detected operation
   lpif_seq_item_h.lpif_operation=ENTER_RECOVERY;
   //sending sequnce item to the anlysis components
   ap_received.write(lpif_seq_item_h); 
 endfunction

//  function void lpif_monitor::notify_enter_l0s_sent ();
//    //creating sequnce item
//    lpif_seq_item lpif_seq_item_h;
//    lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
//    //determining the detected operation
//    lpif_seq_item_h.lpif_operation=ENTER_L0S;
//    //sending sequnce item to the anlysis components
//    ap_sent.write(lpif_seq_item_h);
//   endfunction

//  function void lpif_monitor::notify_enter_l0s_received ();
//    //creating sequnce item
//    lpif_seq_item lpif_seq_item_h;
//    lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
//    //determining the detected operation
//    lpif_seq_item_h.lpif_operation=ENTER_L0S;
//    //sending sequnce item to the anlysis components
//    ap_received.write(lpif_seq_item_h); 
//   endfunction

//  function void lpif_monitor::notify_exit_l0s_sent();
//    //creating sequnce item
//    lpif_seq_item lpif_seq_item_h;
//    lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
//    //determining the detected operation
//    lpif_seq_item_h.lpif_operation=EXIT_L0S;
//    //sending sequnce item to the anlysis components
//    ap_sent.write(lpif_seq_item_h);
//   endfunction

//  function void lpif_monitor::notify_exit_l0s_received();
//    //creating sequnce item
//    lpif_seq_item lpif_seq_item_h;
//    lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
//    //determining the detected operation
//    lpif_seq_item_h.lpif_operation=EXIT_L0S;
//    //sending sequnce item to the anlysis components
//    ap_received.write(lpif_seq_item_h); 
//   endfunction
