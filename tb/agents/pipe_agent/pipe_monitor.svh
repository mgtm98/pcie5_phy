class pipe_monitor extends uvm_monitor;
  // UVM Factory Registration Macro
  `uvm_component_utils(pipe_monitor)
    
  // Virtual Interface
  virtual pipe_monitor_bfm pipe_monitor_bfm_h;
    
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
  extern function void notify_link_up_req();
  extern function void notify_send_tlp(tlp_t tlp);
  extern function void notify_send_dllp(dllp_t dllp);
  extern function void notify_state_change(state_t state);
  extern function void notify_device_speed_mode_change(speed_mode_t speed_mode);
  extern function void notify_reset();
  extern function void notify_pclk_rate_change(bit [4:0] pclk_rate);
  extern function void notify_rate_change(bit [3:0] rate);
  extern function void notify_link_up_res();
  extern function void notify_receive_tlp(tlp_t tlp);
  extern function void notify_receive_dllp(dllp_t dllp);
  extern function void notify_host_speed_mode_change(speed_mode_t speed_mode);

  
endclass: pipe_monitor
   
function pipe_monitor::new(string name = "pipe_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction
  
function void pipe_monitor::build_phase(uvm_phase phase);
  
  // if( !uvm_config_db #( pipe_agent_config )::get( this , "" ,"pipe_agent_config_h" , pipe_agent_config_h )) 
  // begin
  //   `uvm_error("Config Error" , "uvm_config_db #( pipe_agent_config )::get cannot find resource pipe_agent_config" )
  // end

  ap_sent = new("ap_sent", this);
  ap_received = new("ap_received", this);


endfunction: build_phase
    

function void pipe_monitor::connect_phase(uvm_phase phase);
  pipe_monitor_bfm_h = pipe_agent_config_h.pipe_monitor_bfm_h;
  pipe_monitor_bfm_h.proxy = this;
endfunction: connect_phase


function void pipe_monitor::notify_link_up_req();
  //to be implemented
endfunction


function void pipe_monitor::notify_send_tlp(tlp_t tlp);
  //to be implemented
endfunction


function void pipe_monitor::notify_send_dllp(dllp_t dllp);
  //to be implemented
endfunction


function void pipe_monitor::notify_state_change(state_t state);
  //to be implemented
endfunction


function void pipe_monitor::notify_device_speed_mode_change(speed_mode_t speed_mode);
  //to be implemented
endfunction


function void pipe_monitor::notify_reset();
  //to be implemented
endfunction


function void pipe_monitor::notify_pclk_rate_change(bit [4:0] pclk_rate);
  //to be implemented
endfunction


function void pipe_monitor::notify_rate_change(bit [3:0] rate);
  //to be implemented
endfunction


function void pipe_monitor::notify_link_up_res();
  //to be implemented
endfunction


function void pipe_monitor::notify_receive_tlp(tlp_t tlp);
  //to be implemented
endfunction


function void pipe_monitor::notify_receive_dllp(dllp_t dllp);
  //to be implemented
endfunction


function void pipe_monitor::notify_host_speed_mode_change(speed_mode_t speed_mode);
  //to be implemented
endfunction