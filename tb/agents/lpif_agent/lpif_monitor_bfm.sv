`include "settings.svh"

interface lpif_monitor_bfm#(
  localparam bus_data_width_param = `LPIF_BUS_WIDTH - 1,
  localparam bus_kontrol_param = (`LPIF_BUS_WIDTH/8) - 1
)
(
  input logic lclk,
  input logic                                pl_trdy,
  input logic [bus_data_width_param:0]       pl_data,
  input logic [bus_kontrol_param:0]          pl_valid,
  
  input logic                               lp_irdy,
  input logic [bus_data_width_param:0]      lp_data,
  input logic [bus_kontrol_param:0]         lp_valid,
  
  input logic [3:0]                         lp_state_req,
  input logic [3:0]                         pl_state_sts,
  input logic                               lp_force_detect,
  
  input logic [2:0]                          pl_speed_mode,
  
  input logic [bus_kontrol_param:0]          pl_tlp_start,
  input logic [bus_kontrol_param:0]          pl_tlp_end,
  input logic [bus_kontrol_param:0]          pl_dllp_start,
  input logic [bus_kontrol_param:0]          pl_dllp_end,
  input logic [bus_kontrol_param:0]          pl_tlpedb,
  
  input logic [bus_kontrol_param:0]         lp_tlp_start,
  input logic [bus_kontrol_param:0]         lp_tlp_end,
  input logic [bus_kontrol_param:0]         lp_dllp_start,
  input logic [bus_kontrol_param:0]         lp_dllp_end,
  input logic [bus_kontrol_param:0]         lp_tlpedb
);

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import lpif_agent_pkg::*;

  lpif_monitor proxy;
  logic [3:0]  pl_state_sts_previous;

  // Detect Link up 
  initial begin
    forever begin
      @(pl_state_sts)begin
        if(pl_state_sts_previous == LINK_RESET && pl_state_sts == ACTIVE) proxy.notify_link_up_received();
        pl_state_sts_previous = pl_state_sts;
      end
    end
  end
    
endinterface