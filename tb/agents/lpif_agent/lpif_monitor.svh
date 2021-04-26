`define NOTIFY_LPIF_OP_SENT(func_name, lpif_op) \
    function void notify_``func_name``_sent();\
      lpif_seq_item lpif_seq_item_h  = lpif_seq_item::type_id::create("lpif_seq_item_h");\
      lpif_seq_item_h.lpif_operation = ``lpif_op``;\
      ap_sent.write(lpif_seq_item_h);\
    endfunction

`define NOTIFY_LPIF_OP_RECIEVED(func_name, lpif_op) \
    function void notify_``func_name``_received();\
      lpif_seq_item lpif_seq_item_h  = lpif_seq_item::type_id::create("lpif_seq_item_h");\
      lpif_seq_item_h.lpif_operation = ``lpif_op``;\
      ap_received.write(lpif_seq_item_h);\
    endfunction

`define NOTIFY_LPIF_OP_SENT_EXTENDED(func_name, lpif_op, lpif_data_field_type, lpif_data_field) \
    function void notify_``func_name``_sent(``lpif_data_field_type`` ``lpif_data_field``);\
      lpif_seq_item lpif_seq_item_h  = lpif_seq_item::type_id::create("lpif_seq_item_h");\
      lpif_seq_item_h.lpif_operation = ``lpif_op``;\
      lpif_seq_item_h.``lpif_data_field`` = new ``lpif_data_field``;\
      ap_sent.write(lpif_seq_item_h);\
    endfunction

`define NOTIFY_LPIF_OP_RECIEVED_EXTENDED(func_name, lpif_op, lpif_data_field_type, lpif_data_field) \
    function void notify_``func_name``_received(``lpif_data_field_type`` ``lpif_data_field``);\
      lpif_seq_item lpif_seq_item_h  = lpif_seq_item::type_id::create("lpif_seq_item_h");\
      lpif_seq_item_h.lpif_operation = ``lpif_op``;\
      lpif_seq_item_h.``lpif_data_field`` = new ``lpif_data_field``;\
      ap_received.write(lpif_seq_item_h);\
    endfunction


/******************************** Class Header ********************************************/
class lpif_monitor extends uvm_monitor;
 
  `uvm_component_utils(lpif_monitor);               // UVM Factory Registration Macro
  virtual lpif_monitor_bfm_param lpif_monitor_bfm_h;      // BFM handle
  lpif_agent_config lpif_agent_config_h;            // Config object handle
  uvm_analysis_port #(lpif_seq_item) ap_sent;       // RX Analysis Port
  uvm_analysis_port #(lpif_seq_item) ap_received;   // TX Analysis Port
  
  //------------------------------------------
  //  Notification Methods
  //------------------------------------------
  `NOTIFY_LPIF_OP_SENT(link_up, LINK_UP)
  `NOTIFY_LPIF_OP_SENT(reset, RESET)
  `NOTIFY_LPIF_OP_SENT(retrain, ENTER_RECOVERY)

  `NOTIFY_LPIF_OP_RECIEVED(link_up, LINK_UP)
  `NOTIFY_LPIF_OP_RECIEVED(reset, RESET)
  `NOTIFY_LPIF_OP_RECIEVED(retrain, ENTER_RECOVERY)

  `NOTIFY_LPIF_OP_SENT_EXTENDED(dllp, DLLP_TRANSFER, dllp_t, dllp)
  `NOTIFY_LPIF_OP_SENT_EXTENDED(tlp, TLP_TRANSFER, tlp_t, tlp)
  `NOTIFY_LPIF_OP_RECIEVED_EXTENDED(dllp, DLLP_TRANSFER, dllp_t, dllp)
  `NOTIFY_LPIF_OP_RECIEVED_EXTENDED(tlp, TLP_TRANSFER, tlp_t, tlp)
  
  //------------------------------------------
  //  Standard UVM Methods
  //------------------------------------------
  extern function new(string name = "lpif_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass: lpif_monitor
/*******************************************************************************************/

/********************************* Class Implementation ************************************/
function lpif_monitor::new(string name = "lpif_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction
  
function void lpif_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info (get_type_name (), "building lpif monitor", `COMPONENT_STRUCTURE_VERBOSITY)
  ap_sent = new("ap_sent",this);
  ap_received = new("ap_received",this);
  `uvm_info (get_type_name (), "lpif monitor built", `COMPONENT_STRUCTURE_VERBOSITY)
endfunction
  
function void lpif_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info (get_type_name (), "connecting lpif monitor", `COMPONENT_STRUCTURE_VERBOSITY)
  //getting bfm handle from the agent config object
  lpif_monitor_bfm_h = lpif_agent_config_h.lpif_monitor_bfm_h;

  lpif_monitor_bfm_h.proxy = this;  //passing proxy of the monitor to the bfm
  `uvm_info (get_type_name (), "lpif monitor connected", `COMPONENT_STRUCTURE_VERBOSITY)
endfunction