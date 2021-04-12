interface lpif_driver_bfm(input logic lclk);
  
  localparam bus_data_width_param = LPIF_BUS_WIDTH - 1; 
  localparam bus_kontrol_param = (LPIF_BUS_WIDTH/8) - 1;

  logic                               pl_trdy;
  logic [bus_data_width_param:0]      pl_data;
  logic [bus_kontrol_param:0]         pl_valid;
  
  logic                               lp_irdy;
  logic [bus_data_width_param:0]      lp_data;
  logic [bus_kontrol_param:0]         lp_valid;
  
  logic [3:0]                         lp_state_req;
  logic [3:0]                         pl_state_sts;
  logic                               lp_force_detect;
  
  logic [2:0]                         pl_speed_mode;
  
  logic [bus_kontrol_param:0]         pl_tlp_start;
  logic [bus_kontrol_param:0]         pl_tlp_end;
  logic [bus_kontrol_param:0]         pl_dllp_start;
  logic [bus_kontrol_param:0]         pl_dllp_end;
  logic [bus_kontrol_param:0]         pl_tlpedb;
  
  logic [bus_kontrol_param:0]         lp_tlp_start;
  logic [bus_kontrol_param:0]         lp_tlp_end;
  logic [bus_kontrol_param:0]         lp_dllp_start;
  logic [bus_kontrol_param:0]         lp_dllp_end;
  logic [bus_kontrol_param:0]         lp_tlpedb;
  
//  logic                               pl_exit_cg_req;
//  logic                               lp_exit_cg_ack;

  modport bfm(
    input  pl_trdy, pl_data, pl_valid, pl_state_sts, pl_tlp_start,
           pl_tlp_end, pl_dllp_start, pl_dllp_end, pl_tlpedb, pl_exit_cg_req,
    
    output lp_irdy, lp_data, lp_valid, lp_state_req, lp_force_detect, pl_speed_mode,
           lp_tlp_start, lp_tlp_end, lp_dllp_start, lp_dllp_end, lp_tlpedb, lp_exit_cg_ack
  );
  
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import common_pkg::*;


  task link_up();
    pl_state_sts <= LinkReset;
    pl_trdy <= 0;
    lp_state_req <= Active;
    wait(pl_state_sts == Active);
  endtask


  task send_tlp(tlp_t tlp);
    //to be implemented
  endtask


  task send_dllp(dllp_t dllp);
    //to be implemented
  endtask

  // task reset ();
  //   //to be implemented
  // endtask

  task change_speed(speed_mode_t speed);
    //to be implemented
  endtask

  task retrain();
    //to be implemented
  endtask
  
endinterface
