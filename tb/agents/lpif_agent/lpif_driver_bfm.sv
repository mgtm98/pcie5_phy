interface lpif_driver_bfm(
  input bit clk,
  output bit reset,
  // TODO Change the size of data, valid, tlp_start, tlp_end, dllp_start, dlp_end
  // add proxy 
  output logic [7:0][7:0] data,
  output logic [7:0] valid,
  output logic irdy,
  input logic ex_cg_req,
  output logic ex_cg_ack,
  output logic [3:0] state_req,
  output logic stall_ack,
  input logic [8:0] tlp_start,
  input logic [8:0] tlp_end,
  input logic [8:0] dllp_start,
  input logic [8:0] dllp_end,
  input logic block_dl_init,
  input logic protocol_valid,
  input logic [2:0] protocol,
  input logic link_up,
  input logic [3:0] state_sts,
  input logic trdy,
  input logic phyinrecenter,
  input logic rxframe_errmask,
  input logic [2:0] link_cfg,
  input logic stall_req,
  input logic phyinl1
);
