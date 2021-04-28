`include "settings.svh"

interface lpif_driver_bfm #(
  param lpif_bus_width,
  localparam bus_data_width_param = lpif_bus_width - 1; 
  localparam bus_kontrol_param = (lpif_bus_width/8) - 1;
)(
    input logic lclk,
    input logic                                pl_trdy,
    input logic [bus_data_width_param:0]       pl_data,
    input logic [bus_kontrol_param:0]          pl_valid,
    
    output logic                               lp_irdy,
    output logic [bus_data_width_param:0]      lp_data,
    output logic [bus_kontrol_param:0]         lp_valid,
    
    output logic [3:0]                         lp_state_req,
    input logic [3:0]                          pl_state_sts,
    output logic                               lp_force_detect,
    
    input logic [2:0]                          pl_speed_mode,
    
    input logic [bus_kontrol_param:0]          pl_tlp_start,
    input logic [bus_kontrol_param:0]          pl_tlp_end,
    input logic [bus_kontrol_param:0]          pl_dllp_start,
    input logic [bus_kontrol_param:0]          pl_dllp_end,
    input logic [bus_kontrol_param:0]          pl_tlpedb,
    
    output logic [bus_kontrol_param:0]         lp_tlp_start,
    output logic [bus_kontrol_param:0]         lp_tlp_end,
    output logic [bus_kontrol_param:0]         lp_dllp_start,
    output logic [bus_kontrol_param:0]         lp_dllp_end,
    output logic [bus_kontrol_param:0]         lp_tlpedb
  );

  `include "uvm_macros.svh"
  import lpif_agent_pkg::*;
  import uvm_pkg::*;
  import common_pkg::*;

  task link_up ();
  	lp_state_req <= LINK_RESET;
    wait(pl_state_sts == LINK_RESET);
  	@(posedge lclk);
    lp_state_req <= ACTIVE;
    wait(pl_state_sts == ACTIVE);
  	@(posedge lclk);
  endtask

  task send_tlp(tlp_t tlp);
    //to be implemented
  endtask


  task send_dllp(dllp_t dllp);
    //to be implemented
  endtask

  task reset ();
    //to be implemented
  endtask

  // task change_speed(speed_mode_t speed);
  //   //to be implemented
  // endtask

  task retrain();
    //to be implemented
  endtask
  
endinterface
