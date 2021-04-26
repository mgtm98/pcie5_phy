`include "settings.svh"

interface lpif_if #(
  param lpif_bus_width,
  localparam bus_data_width_param = lpif_bus_width - 1; 
  localparam bus_kontrol_param = (lpif_bus_width/8) - 1;
)();

  logic                               lclk;

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

  logic                               pl_exit_cg_req;
  logic                               lp_exit_cg_ack;

  // logic [bus_kontrol_param:0]         pl_k_char;
  // logic [bus_kontrol_param:0]         lp_k_char;

  // logic                               pl_block_dl_init;

  // logic [2:0]                         pl_link_cfg;
  // logic                               pl_lnk_up;

  // logic                               pl_stall_req;
  // logic                               lp_stall_ack;

endinterface: lpif_if
