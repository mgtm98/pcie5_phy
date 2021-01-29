class pipe_monitor extends uvm_monitor;
  // UVM Factory Registration Macro
    `uvm_component_utils(pipe_monitor);
    
  // Virtual Interface
  virtual pipe_monitor_bfm pipe_monitor_bfm_h;
    
  //------------------------------------------
  // Data Members
  //------------------------------------------
  pipe_monitor_config pipe_monitor_config_h;
  
  //------------------------------------------
  // Component Members
  //------------------------------------------
  uvm_analysis_port #(pipe_seq_item) ap;
  
  //------------------------------------------
  // Methods
  //------------------------------------------
  
  // Standard UVM Methods:
  extern function new(string name = "pipe_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);

  //extern task run_phase(uvm_phase phase); 
  //not mentioned in the document!?


  // Proxy Methods:
  extern function void notify_link_up_req();
  extern function void notify_send_tlp(tlp_s tlp);
  extern function void notify_send_dllp(dllp_s dllp);
  extern function void notify_state_change(state_e state);
  extern function void notify_device_speed_mode_change(speed_mode_e speed_mode);
  extern function void notify_reset();
  extern function void notify_pclk_rate_change(bit [4:0] pclk_rate);
  extern function void notify_rate_change(bit [3:0] rate);
  extern function void notify_link_up_res();
  extern function void notify_receive_tlp(tlp_s tlp);
  extern function void notify_receive_dllp(dllp_s dllp);
  extern function void notify_host_speed_mode_change(speed_mode_e speed_mode);

  
endclass: pipe_monitor
   
function pipe_monitor::new(string name = "pipe_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction
  
function void pipe_monitor::build_phase(uvm_phase phase);
  
  //super.build_pahse(phase);
  //should this be called ?

  if( !uvm_config_db #( pipe_monitor_config )::get( this , "" ,"pipe_monitor_config_h" , pipe_monitor_config_h )) 
  begin
    `uvm_error("Config Error" , "uvm_config_db #( pipe_monitor_config )::get cannot find resource pipe_monitor_config" )
  end

  pipe_monitor_bfm_h = pipe_monitor_config_h.pipe_monitor_bfm_h;

  //pipe_monitor_bfm_h.proxy = this;
  //not mentioned in the document

  ap = new("ap", this);

endfunction: build_phase
    


/*

//not mentioned in the document

task pipe_monitor::run_phase(uvm_phase phase);
  pipe_monitor_bfm_h.run();
endtask
*/
        

function void pipe_monitor::notify_link_up_req();
  //to be implemented
endfunction


function void pipe_monitor::notify_send_tlp(tlp_s tlp);
  //to be implemented
endfunction


function void pipe_monitor::notify_send_dllp(dllp_s dllp);
  //to be implemented
endfunction


function void pipe_monitor::notify_state_change(state_e state);
  //to be implemented
endfunction


function void pipe_monitor::notify_device_speed_mode_change(speed_mode_e speed_mode);
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


function void pipe_monitor::notify_receive_tlp(tlp_s tlp);
  //to be implemented
endfunction


function void pipe_monitor::notify_receive_dllp(dllp_s dllp);
  //to be implemented
endfunction


function void pipe_monitor::notify_host_speed_mode_change(speed_mode_e speed_mode);
  //to be implemented
endfunction