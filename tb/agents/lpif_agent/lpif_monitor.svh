class lpif_monitor extends uvm_monitor;
  `uvm_component_utils(lpif_monitor);
  
  virtual lpif_monitor_bfm lpif_monitor_bfm_h;
  Lpif_agent_config lpif_agent_config_h;    
  uvm_analysis_port #(lpif_seq_item) ap_sent;
  uvm_analysis_port #(lpif_seq_item) ap_received;
  
  //------------------------------------------
  //  notification Methods
  //------------------------------------------
  extern function void notify_link_up_sent();
  extern function void notify_link_up_received();
  extern function void notify_tlp_sent(tlp_s tlp);
  extern function void notify_dllp_sent(dllp_s dllp);
  extern function void notify_tlp_received(tlp_s tlp);
  extern function void notify_dllp_received(dllp_s dllp);
  extern function void notify_reset_received();
  extern function void notify_reset_sent();
  extern function void notify_speed_mode_change_sent();
  extern function void notify_speed_mode_change_received();
  extern function void notify_retrain_sent ();
  extern function void notify_retrain_received ();
  extern function void notify_enter_l0s_sent ();
  extern function void notify_enter_l0s_received ();
  extern function void notify_exit_l0s_sent();
  extern function void notify_exit_l0s_received();

    
    
    // Standard UVM Methods:
  extern function new(string name = "lpif_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  
endclass: pipe_monitor
    
function pipe_monitor::new(string name = "pipe_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction
    
function void lpif_monitor::build_phase(uvm_phase phase);
  
  super.build_pahse(phase);
  
  //getting bfm handle from the agent config object
  lpif_monitor_bfm_h = lpif_agent_config_h.lpif_monitor_bfm_h;  
  
  //analysis ports creation
  ap_sent=new("ap_sent",this);
  ap_received=new("ap_received",this);
  
  //passing proxy of the monitor to the bfm
  lpif_monitor_bfm_h.lpif_monitor_proxy = this;
  
endfunction
    
    
 function void lpif_monitor::notify_link_up_sent();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=LINK_UP;
   ap_sent.write(lpif_seq_item_h);
 	endfunction
    
 function void lpif_monitor::notify_link_up_received();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=LINK_UP;
   ap_received.write(lpif_seq_item_h);
 	endfunction  
    
 function void lpif_monitor::notify_tlp_sent(tlp_s tlp);
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=TLP_TRANSFER;
   ap_sent.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_dllp_sent(dllp_s dllp);
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=DLLP_TRANSFER;
   ap_sent.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_tlp_received(tlp_s tlp);
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=TLP_TRANSFER;
   ap_received.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_dllp_received(dllp_s dllp);
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=DLLP_TRANSFER;
   ap_received.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_reset_received();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=RESET;
   ap_received.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_reset_sent();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=RESET;
   ap_sent.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_speed_mode_change_sent();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=SPEED_CHANGE;
   ap_sent.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_speed_mode_change_received();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=SPEED_CHANGE;
   ap_received.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_retrain_sent ();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=ENTER_RECOVERY;
   ap_sent.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_retrain_received ();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=ENTER_RECOVERY;
   ap_received.write(lpif_seq_item_h); 
    endfunction
    
 function void lpif_monitor::notify_enter_l0s_sent ();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=ENTER_L0S;
   ap_sent.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_enter_l0s_received ();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=ENTER_L0S;
   ap_received.write(lpif_seq_item_h); 
    endfunction
    
 function void lpif_monitor::notify_exit_l0s_sent();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=EXIT_L0S;
   ap_sent.write(lpif_seq_item_h);
    endfunction
    
 function void lpif_monitor::notify_exit_l0s_received();
   lpif_seq_item lpif_seq_item_h;
   lpif_seq_item_h = lpif_seq_item::type_id::create("lpif_seq_item_h", this);
   lpifseq_item_f.lpif_operation=EXIT_L0S;
   ap_received.write(lpif_seq_item_h); 
    endfunction
