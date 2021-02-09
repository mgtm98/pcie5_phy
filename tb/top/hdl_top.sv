module hdl_top;

// clk and reset
//
logic clk;
logic reset;

//
// Instantiate the pin interfaces:
//
lpif_if LPIF(clk, reset);   // LPIF interface
pipe_if PIPE(clk, reset);  // PIPE Interface                                      // NA2IS L PARAMETRISE LMA YKHLS

//
// Instantiate the BFM interfaces:
//
lpif_monitor_bfm LPIF_mon_bfm(
  .clk             (LPIF.clk),
  .reset           (LPIF.reset),

  .data            (LPIF.data),
  .valid           (LPIF.valid),
  .irdy            (LPIF.irdy),
  .ex_cg_req       (LPIF.ex_cg_req),
  .ex_cg_ack       (LPIF.ex_cg_ack),
  .state_req       (LPIF.state_req),
  .stall_ack       (LPIF.stall_ack),
  .tlp_start       (LPIF.tlp_start),
  .tlp_end         (LPIF.tlp_end),
  .dllp_start      (LPIF.dllp_start),
  .dllp_end        (LPIF.dllp_end),
  .block_dl_init   (LPIF.block_dl_init),
  .protocol_valid  (LPIF.protocol_valid),
  .protocol        (LPIF.protocol),
  .link_up         (LPIF.link_up),
  .state_sts       (LPIF.state_sts),
  .trdy            (LPIF.trdy),
  .phyinrecenter   (LPIF.phyinrecenter),
  .rxframe_errmask (LPIF.rxframe_errmask),
  .link_cfg        (LPIF.link_cfg),
  .stall_req       (LPIF.stall_req),
  .phyinl1         (LPIF.phyinl1)
);

lpif_driver_bfm LPIF_drv_bfm(
	.clk             (LPIF.clk),
	.reset           (LPIF.reset),

	.data            (LPIF.data),
	.valid           (LPIF.valid),
	.irdy            (LPIF.irdy),
	.ex_cg_req       (LPIF.ex_cg_req),
	.ex_cg_ack       (LPIF.ex_cg_ack),
	.state_req       (LPIF.state_req),
	.stall_ack       (LPIF.stall_ack),
	.tlp_start       (LPIF.tlp_start),
	.tlp_end         (LPIF.tlp_end),
	.dllp_start      (LPIF.dllp_start),
	.dllp_end        (LPIF.dllp_end),
	.block_dl_init   (LPIF.block_dl_init),
	.protocol_valid  (LPIF.protocol_valid),
	.protocol        (LPIF.protocol),
	.link_up         (LPIF.link_up),
	.state_sts       (LPIF.state_sts),
	.trdy            (LPIF.trdy),
	.phyinrecenter   (LPIF.phyinrecenter),
	.rxframe_errmask (LPIF.rxframe_errmask),
	.link_cfg        (LPIF.link_cfg),
	.stall_req       (LPIF.stall_req),
	.phyinl1         (LPIF.phyinl1)
);

pipe_monitor_bfm PIPE_mon_bfm(
  .clk            (PIPE.clk),
  .reset          (PIPE.reset),
   
  .RxData         (PIPE.rx_data),
  .RxDataK        (PIPE.rx_data_k),
  .RxValid        (PIPE.rx_valid),
  .PhyStatus      (PIPE.phy_status),
  .RxElecidle     (PIPE.rx_elec_idle),
  .RxStatus       (PIPE.rx_status),
  .RxstartBlock   (PIPE.rx_start_block),
  .RxsynchHeader  (PIPE.rx_synch_Header),
  .TxData         (PIPE.tx_data),
  .TxDataK        (PIPE.tx_data_k),
  .TxDataValid    (PIPE.tx_data_valid),
  .TxDetectRx     (PIPE.tx_detect_rx),
  .TxEelecIdle    (PIPE.tx_elec_idle),
  .Width          (PIPE.width),
  .Rate           (PIPE.rate),
  .PCLK           (PIPE.pclk),
  .PCLKRate       (PIPE.pclk_rate),
  .Reset#         (PIPE.reset#),
  .TxStartBlock   (PIPE.tx_start_block),
  .TxSynchHeader  (PIPE.tx_synch_header),
  .Powerdown      (PIPE.power_down)
);

pipe_driver_bfm PIPE_drv_bfm(
  .clk            (PIPE.clk),
  .reset          (PIPE.reset),
   
  .RxData         (PIPE.RxData),
  .RxDataK        (PIPE.RxDataK),
  .RxValid        (PIPE.RxValid),
  .PhyStatus      (PIPE.PhyStatus),
  .RxElecidle     (PIPE.RxElecidle),
  .RxStatus       (PIPE.RxStatus),
  .RxstartBlock   (PIPE.RxstartBlock),
  .RxsynchHeader  (PIPE.RxsynchHeader),
  .TxData         (PIPE.TxData),
  .TxDataK        (PIPE.TxDataK),
  .TxDataValid    (PIPE.TxDataValid),
  .TxDetectRx     (PIPE.TxDetectRx),
  .TxEelecIdle    (PIPE.TxEelecIdle),
  .Width          (PIPE.Width),
  .Rate           (PIPE.Rate),
  .PCLK           (PIPE.PCLK),
  .PCLKRate       (PIPE.PCLKRate),
  .Reset#         (PIPE.Reset#),
  .TxStartBlock   (PIPE.TxStartBlock),
  .TxSynchHeader  (PIPE.TxSynchHeader),
  .Powerdown      (PIPE.Powerdown)
);

  
// DUT
// pcie_top DUT(
//     // PCIE Interface:
// );


// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin //tbx vif_binding_block
  import uvm_pkg::uvm_config_db;
  uvm_config_db #(virtual lpif_monitor_bfm)::set(null, "uvm_test_top", "lpif_monitor_bfm", LPIF_mon_bfm);
  uvm_config_db #(virtual lpif_driver_bfm) ::set(null, "uvm_test_top", "lpif_driver_bfm", LPIF_drv_bfm);
  uvm_config_db #(virtual pipe_monitor_bfm)::set(null, "uvm_test_top", "pipe_monitor_bfm", PIPE_mon_bfm);
  uvm_config_db #(virtual pipe_driver_bfm) ::set(null, "uvm_test_top", "pipe_driver_bfm", PIPE_drv_bfm);
end

//
// Clock and reset initial block:
//
initial begin
  clk = 0;
  forever #10ns clk = ~clk;
end
// initial begin 
//   reset = 0;
//   repeat(4) @(posedge clk);
//   reset = 1;
// end

endmodule: hdl_top
