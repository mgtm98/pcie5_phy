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
	.lclk                   (LPIF.lclk),
  .pl_trdy                (LPIF.pl_trdy),
	.pl_data                (LPIF.pl_data),
	.pl_valid               (LPIF.pl_valid),
	.lp_irdy                (LPIF.lp_irdy),
	.lp_data                (LPIF.lp_data),
	.lp_valid               (LPIF.lp_valid),
	.lp_state_req           (LPIF.lp_state_req),
	.pl_state_sts           (LPIF.pl_state_sts),
	.lp_force_detect        (LPIF.lp_force_detect),
	.pl_speed_mode          (LPIF.pl_speed_mode),

	.pl_tlp_start           (LPIF.pl_tlp_start),
	.pl_tlp_end             (LPIF.pl_tlp_end),
	.pl_dllp_start          (LPIF.pl_dllp_start),
	.pl_dllp_end            (LPIF.pl_dllp_end),
	.pl_tlpedb              (LPIF.pl_tlpedb),
 
	.lp_tlp_start           (LPIF.lp_tlp_start),
	.lp_tlp_end             (LPIF.lp_tlp_end),
	.lp_dllp_start          (LPIF.lp_dllp_start),
	.lp_dllp_end            (LPIF.lp_dllp_end),
	.lp_tlpedb              (LPIF.lp_tlpedb),

//	.pl_exit_cg_req         (LPIF.pl_exit_cg_req),
//	.lp_exit_cg_ack         (LPIF.lp_exit_cg_ack),
);

lpif_driver_bfm.bfm LPIF_drv_bfm(
	.lclk                   (LPIF.lclk),
  .pl_trdy                (LPIF.pl_trdy),
	.pl_data                (LPIF.pl_data),
	.pl_valid               (LPIF.pl_valid),
	.lp_irdy                (LPIF.lp_irdy),
	.lp_data                (LPIF.lp_data),
	.lp_valid               (LPIF.lp_valid),
	.lp_state_req           (LPIF.lp_state_req),
	.pl_state_sts           (LPIF.pl_state_sts),
	.lp_force_detect        (LPIF.lp_force_detect),
	.pl_speed_mode          (LPIF.pl_speed_mode),

	.pl_tlp_start           (LPIF.pl_tlp_start),
	.pl_tlp_end             (LPIF.pl_tlp_end),
	.pl_dllp_start          (LPIF.pl_dllp_start),
	.pl_dllp_end            (LPIF.pl_dllp_end),
	.pl_tlpedb              (LPIF.pl_tlpedb),

	.lp_tlp_start           (LPIF.lp_tlp_start),
	.lp_tlp_end             (LPIF.lp_tlp_end),
	.lp_dllp_start          (LPIF.lp_dllp_start),
	.lp_dllp_end            (LPIF.lp_dllp_end),
	.lp_tlpedb              (LPIF.lp_tlpedb),

//	.pl_exit_cg_req         (LPIF.pl_exit_cg_req),
//	.lp_exit_cg_ack         (LPIF.lp_exit_cg_ack),
);

pipe_monitor_bfm PIPE_mon_bfm(
  .CLK                      (PIPE.CLK), 
  .RxData                  (PIPE.RxData),
  .RxDataK                (PIPE.RxDataK),
  .RxValid                 (PIPE.RxValid),
  .PhyStatus               (PIPE.PhyStatus),
  .RxElecldle             (PIPE.RxElecldle),
  .RxStatus                (PIPE.RxStatus),
  .RxStartBlock           (PIPE.RxStartBlock),
  .RxSyncHeader          (PIPE.RxSyncHeader),
  .TxData                  (PIPE.TxData),
  .TxDataK                (PIPE.TxDataK),
  .TxDataValid            (PIPE.TxDataValid),
  .TxDetectRx             (PIPE.TxDetectRx),
  .TxElecIdle             (PIPE.TxElecIdle),
  .Width                    (PIPE.Width),
  .Rate                     (PIPE.Rate),
  .Pclk                     (PIPE.Pclk),
  .PclkRate                (PIPE.PclkRate),
  .Reset                    (PIPE.Reset),                      
  .TxStartBlock           (PIPE.TxStartBlock),
  .TxSyncHeader          (PIPE.TxSyncHeader),
  .PowerDown               (PIPE.PowerDown)
);

pipe_driver_bfm PIPE_drv_bfm(
  .CLK                      (PIPE.CLK), 
  .RxData                  (PIPE.RxData),
  .RxDataK                (PIPE.RxDataK),
  .RxValid                 (PIPE.RxValid),
  .PhyStatus               (PIPE.PhyStatus),
  .RxElecldle             (PIPE.RxElecldle),
  .RxStatus                (PIPE.RxStatus),
  .RxStartBlock           (PIPE.RxStartBlock),
  .RxSyncHeader          (PIPE.RxSyncHeader),
  .TxData                  (PIPE.TxData),
  .TxDataK                (PIPE.TxDataK),
  .TxDataValid            (PIPE.TxDataValid),
  .TxDetectRx             (PIPE.TxDetectRx),
  .TxElecIdle             (PIPE.TxElecIdle),
  .Width                    (PIPE.Width),
  .Rate                     (PIPE.Rate),
  .Pclk                     (PIPE.Pclk),
  .PclkRate                (PIPE.PclkRate),
  .Reset                    (PIPE.Reset),                      
  .TxStartBlock           (PIPE.TxStartBlock),
  .TxSyncHeader          (PIPE.TxSyncHeader),
  .PowerDown               (PIPE.PowerDown)
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
