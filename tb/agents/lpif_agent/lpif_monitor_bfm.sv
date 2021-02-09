interface lpif_monitor_bfm(
  input bit clk,
  input bit reset,
  // TODO Change the size of data, valid, tlp_start, tlp_end, dllp_start, dlp_end
  input logic [7:0][7:0] data,
  input logic [7:0] valid,
  input logic irdy,
  input logic ex_cg_req,
  input logic ex_cg_ack,
  input logic [3:0] state_req,
  input logic stall_ack,
  input logic [7:0] tlp_start,
  input logic [7:0] tlp_end,
  input logic [7:0] dllp_start,
  input logic [7:0] dllp_end,
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

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import lpif_agent_pkg::*;

  lpif_monitor proxy;

  initial
  begin
    forever
    begin
      @(irdy)
      begin
        `uvm_info("lpif_monitor_bfm", "dummy seq_item detected", UVM_MEDIUM)
        proxy.lpif_monitor_dummy();
      end
    end
  end
    
endinterface