module hdl_top;

// clk and reset
//
logic clk;
logic reset;

//
// Instantiate the pin interfaces:
//
lpif_if LPIF(clk);   // LPIF interface
pipe_if PIPE(clk);  // PIPE Interface                                      // NA2IS L PARAMETRISE LMA YKHLS

//
// Instantiate the BFM interfaces:
//
lpif_monitor_bfm LPIF_mon_bfm(
  .clk             (LPIF.clk),
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

lpif_driver_bfm.bfm LPIF_drv_bfm(
	.lclk             (LPIF.lclk),
	.pl_data            (LPIF.pl_data),
	.pl_valid           (LPIF.pl_valid),
	.lp_irdy            (LPIF.lp_irdy),
	.lp_data       (LPIF.lp_data),
	.lp_valid       (LPIF.lp_valid),
	.lp_state_req       (LPIF.lp_state_req),
	.pl_state_sts       (LPIF.pl_state_sts),
	.lp_force_detect       (LPIF.lp_force_detect),
	.pl_speed_mode         (LPIF.pl_speed_mode),



	.pl_tlp_start      (LPIF.pl_tlp_start),
	.pl_tlp_end        (LPIF.pl_tlp_end),
	.pl_dllp_start   (LPIF.pl_dllp_start),

	.pl_dllp_end  (LPIF.pl_dllp_end),
	.pl_tlpedb        (LPIF.pl_tlpedb),

	.lp_tlp_start         (LPIF.lp_tlp_start),
	.lp_tlp_end       (LPIF.lp_tlp_end),
	.lp_dllp_start            (LPIF.lp_dllp_start),
	.lp_dllp_end   (LPIF.lp_dllp_end),
	.lp_tlpedb (LPIF.lp_tlpedb),

	.pl_exit_cg_req        (LPIF.pl_exit_cg_req),
	.lp_exit_cg_ack       (LPIF.lp_exit_cg_ack),
);

pipe_monitor_bfm PIPE_mon_bfm(
  .clk              (PIPE.clk), 
  .rx_data          (PIPE.rx_data),
  .rx_data_k        (PIPE.rx_data_k),
  .rx_valid         (PIPE.rx_valid),
  .phy_status       (PIPE.phy_status),
  .rx_elec_idle     (PIPE.rx_elec_idle),
  .rx_status        (PIPE.rx_status),
  .rx_start_block   (PIPE.rx_start_block),
  .rx_synch_header  (PIPE.rx_synch_header),
  .tx_data          (PIPE.tx_data),
  .tx_data_k        (PIPE.tx_data_k),
  .tx_data_valid    (PIPE.tx_data_valid),
  .tx_detect_rx     (PIPE.tx_detect_rx),
  .tx_elec_idle     (PIPE.tx_elec_idle),
  .width            (PIPE.width),
  .rate             (PIPE.rate),
  .pclk             (PIPE.pclk),
  .pclk_rate        (PIPE.pclk_rate),
  .reset            (PIPE.reset),                      
  .tx_start_block   (PIPE.tx_start_block),
  .tx_synch_header  (PIPE.tx_synch_header),
  .power_down       (PIPE.power_down)
);

pipe_driver_bfm PIPE_drv_bfm(
  .clk              (PIPE.clk),  
  .rx_data          (PIPE.rx_data),
  .rx_data_k        (PIPE.rx_data_k),
  .rx_valid         (PIPE.rx_valid),
  .phy_status       (PIPE.phy_status),
  .rx_elec_idle     (PIPE.rx_elec_idle),
  .rx_status        (PIPE.rx_status),
  .rx_start_block   (PIPE.rx_start_block),
  .rx_synch_header  (PIPE.rx_synch_header),
  .tx_data          (PIPE.tx_data),
  .tx_data_k        (PIPE.tx_data_k),
  .tx_data_valid    (PIPE.tx_data_valid),
  .tx_detect_rx     (PIPE.tx_detect_rx),
  .tx_elec_idle     (PIPE.tx_elec_idle),
  .width            (PIPE.width),
  .rate             (PIPE.rate),
  .pclk             (PIPE.pclk),
  .pclk_rate        (PIPE.pclk_rate),
  .reset            (PIPE.reset),
  .tx_start_block   (PIPE.tx_start_block),
  .tx_synch_header  (PIPE.tx_synch_header),
  .power_down       (PIPE.power_down)
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
