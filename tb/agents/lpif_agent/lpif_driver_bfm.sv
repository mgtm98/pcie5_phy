interface lpif_driver_bfm
  (
    input  bit   clk,
    output bit   reset,
    output logic [7:0][7:0] data,
    output logic [7:0] valid,
    output logic irdy,
    input  logic ex_cg_req,
    output logic ex_cg_ack,
    output logic [3:0] state_req,
    output logic stall_ack,
    input  logic [8:0] tlp_start,
    input  logic [8:0] tlp_end,
    input  logic [8:0] dllp_start,
    input  logic [8:0] dllp_end,
    input  logic block_dl_init,
    input  logic protocol_valid,
    input  logic [2:0] protocol,
    input  logic link_up,
    input  logic [3:0] state_sts,
    input  logic trdy,
    input  logic phyinrecenter,
    input  logic rxframe_errmask,
    input  logic [2:0] link_cfg,
    input  logic stall_req,
    input  logic phyinl1
  );
  
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import pipe_agent_pkg::*;
    
  lpif_driver lpif_driver_proxy;

  //dummy task used only for tesring our work---------------------------------------------------------------------  
  task lpif_driver_bfm_dummy();
   `uvm_info (get_type_name (), $sformatf ("lpif_driver_bfm_dummy is setting irdy to 1"), UVM_MEDIUM)
    irdy=1;
  endtask 
  
  task link_up();
    //to be implemented
  endtask


  task send_tlp(tlp_s tlp);
    //to be implemented
  endtask


  task send_dllp(dllp_s dllp);
    //to be implemented
  endtask

  task reset ();
    //to be implemented
  endtask

  task change_speed(speed_mode_t speed);
    //to be implemented
  endtask

  task retrain();
    //to be implemented
  endtask

  task enter_l0s();
    //to be implemented
  endtask

  task exit_l0s();
    //to be implemented
  endtask
  
endinterface
